<%@ Page Title="커피 주문 메인" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="coffee_order._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="split">
        <!-- 커피 리스트 -->
        <div class="coffee-list" id="coffee-list"> 

        </div>



        <!--주문 리스트-->
        <ul id="coffee-orders" class="list-group">

        </ul>
    </div>

    <!--커피 템플릿-->
    <div class="coffee" id="coffee-template" style="display:none">
        <div class="coffee-box">
            <img src="" />
        </div>
        <span>커피 이름</span>
    </div>

    <!-- 커피 옵션 선택 창-->
    <div class="coffee-option">
        <div class="coffee-option-box">
            <div class="coffee-option-top">
                <img class="coffee-option-img" src=""/>
            </div>
            <ul class="coffee-option-list">
                <li>
                    <span>종류</span>
                    <div class="switch-field" id="타입">
                        
                    </div>
                </li>
                <li>
                    <span>사이즈</span>
                    <div class="switch-field" id="사이즈">
                        
                    </div>
                </li>
                <li>
                    <span>샷 추가</span>
                    <div class="switch-field" id="샷추가">

                    </div>
                </li>
            </ul>
            <input type="button" class="coffee-option-add" value="담기"/>
        </div>
    </div>

    <script>
        var coffee_dic = {};
        var coffee_option = $('.coffee-option');
        var coffee_current = null;
        var coffee_orders = null;
        var split = null;

        // radio 버튼 동적 생성
        function make_radio_button(option_name, opt_list) {
            var result = '';
            $.each(opt_list, function(index, value) {
                var id =  option_name + index;
                result += '<input type="radio" id="' + id + '" name="' + option_name + '"' + ' value="' + value + '"' + (index == 0 ? ' checked' : '') + '/>';
                result += '<label for="' + id + '">' + value + '</label>';
            });
            return result;
        }

        // 팝업 열기
        function popup_open() {
            coffee_current = null;
            $('.coffee-option').css('display', 'flex');
        }

        // 팝업 닫기
        function popup_close() {
            coffee_option.css('display', 'none');
            coffee_current = null;
        }

        // 데이터 요청 (Default.aspx/GetData)
        function get_data(cmd, success) {
            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                url: '<%= ResolveUrl("Default.aspx/GetData") %>',
                data: JSON.stringify({cmd:cmd}),
                async: false,
                success: function (response) {
                    var data = JSON.parse(response.d);
                    if (data['result'] == 'success') {
                        success(data['data']);
                    }
                    else {
                        alert('error : ' + data['data']);
                    }
                },
                error: function (response) {
                    alert('error');
                },
                complete : function() {}
            });
        }
        // 데이터 설정 (Default.aspx/SetData)
        function set_data(cmd, data, success) {
            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                url: '<%= ResolveUrl("Default.aspx/SetData") %>',
                data: JSON.stringify({cmd:cmd, data:data}),
                async: false,
                success: function (response) {
                    var data = JSON.parse(response.d);
                    if (data['result'] == 'success') {
                        success(data['data']);
                    }
                    else {
                        alert('error : ' + data['data']);
                    }
                },
                error: function (response) {
                    alert('error');
                },
                complete : function() {}
            });
        }

        // 커피 목록 받아오기
        function get_coffees() {
            var success = function (data) {
                    // 커피 목록 비우기
                    $('.coffee-list').html('');

                    coffee_dic = data;
                    // 커피 목록 갱신하기
                    $.each(coffee_dic, function(coffee_name, coffee) {
                        var html = $('#coffee-template').clone();
                        html.attr('id', coffee['이름']);
                        html.css('display', 'block');
                        html.children('span').text(coffee['이름']);
                        html.children('.coffee-box').children('img').attr('src', coffee['이미지']);
                        $('.coffee-list').append(html);
                    });

                    // 커피 클릭 이벤트 등록하기
                    $('.coffee-box').click(function() {
                        popup_open();

                        var coffee = coffee_dic[$(this).parent().attr('id')];
                        $('.coffee-option-img').attr('src', coffee['이미지']);
                        
                        // 옵션 설정하기
                        $.each(coffee['옵션'], function(opt_name, opt_list) {
                            $('#' + opt_name).html(make_radio_button(opt_name, opt_list));
                        });
                        coffee_current = coffee;
                    });
                }

           get_data('get_coffees', success);
        }
        
        
        // 커피 주문 목록 받아오기
        function get_orders() {
            var success = function(data) {
                
                var li = '';
                var orders = data;
                $.each(orders, function(key, value) {
                    li += '<li class="list-group-item" name="' + key + '"><div class="list-group-item-container">' + 
                        '<img class="list-group-item-img" src="' + value['이미지'] +'"/>' +
                        '<div class="list-group-item-overlay"><p class="list-group-item-overlay-text">삭제</p></div></div>' +
                        '<details><summary>' + value["이름"] + '(' + value['주문자'] + ')</summary>' + 
                            '<p class="list-group-item-option">' + JSON.stringify(value['옵션']) + '</p></details></li>'
                });
                $('#coffee-orders').html(li);
                $('.list-group-item-container').click(function(){
                    remove_order($(this).parent().attr('name'));
                });
                coffee_orders = Sortable.create(document.getElementById('coffee-orders'), {
                    sort : false,
                    });
            }
            get_data('get_orders', success);
        }

        // 커피 주문하기
        function add_order() {
            if (coffee_current == null) {
                alert('오류! 선택된 커피가 없습니다.');
            }
            var coffee = $.extend(true, {}, coffee_current);
            var options = Object.keys(coffee['옵션']);
            $.each(options, function(index, value) {
                coffee['옵션'][value] = $("input[name='" + value + "']:checked").val()
            });

            var success = function () {
                get_orders();
            }

            set_data('add_order', JSON.stringify(coffee), success)
        }

        // 커피 주문 취소하기
        function remove_order(id) {
            var success = function () {
                get_orders();
            }
            set_data('remove_order', id, success);
        }

        // 문서 준비 완료
        $(document).ready(function() {
            /* 이름 확인하기 */
            get_data("get_name", function (data) {
                // 이름 없는 경우
                if (data == "") {
                    var name = prompt('사용자 이름을 입력해주세요', '이름');
                    if (name != null && name != "") {
                        set_data("set_name", name, function(data) {
                            alert(data);
                            location.reload();
                        });
                    }
                    else {
                        alert("주문을 위해서 반드시 이름이 필요합니다.");
                        location.reload();
                    }
                }
                else {
                    split = Split(['#coffee-list', '#coffee-orders'], {
                        minSize: 240,
                    });

                    get_coffees();
                    get_orders();
                    // 팝업 닫기
                    $(document).mouseup(function (e){
                        if(coffee_option.has(e.target).length==0) {
                            popup_close(); 
                        } 
                    });

                    // 커피 추가하기
                    $('.coffee-option-add').click(function() {
                        add_order();
                        popup_close(); 
                    });
                }
            });    
        });
    </script>
</asp:Content>
