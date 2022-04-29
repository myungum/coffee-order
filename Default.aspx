<%@ Page Title="커피 주문 메인" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="coffee_order._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- 커피 리스트 -->
    <div class="coffee-list">
        

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
        
        function make_radio_button(option_name, opt_list) {
            var result = '';
            $.each(opt_list, function(index, value) {
                var id =  option_name + index;
                result += '<input type="radio" id="' + id + '" name="' + option_name + '"' + (index == 0 ? ' checked' : '') + '/>';
                result += '<label for="' + id + '">' + value + '</label>';
            });
            return result;
        }

        $(document).ready(function() {
            
            var obj = {cmd : 'get_coffees', data:''}
            // 커피 목록 받아오기
            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                url: '<%= ResolveUrl("Default.aspx/RequestData") %>',
                data: JSON.stringify(obj),
                async: false,
                success: function (response) {
                    // 커피 목록 비우기
                    $('.coffee-list').html('');

                    var data = JSON.parse(response.d)['data'];
                    // 커피 목록 갱신하기
                    $.each(data, function(coffee_name, coffee) {
                        var html = $('#coffee-template').clone();
                        html.attr('id', coffee_name);
                        html.css('display', 'block');
                        html.children('span').text(coffee_name);
                        html.children('.coffee-box').children('img').attr('src', coffee['이미지']);
                        $('.coffee-list').append(html);
                    });
                    coffee_dic = data;

                    // 커피 클릭 이벤트 등록하기
                    $('.coffee-box').click(function() {
                        var coffee = coffee_dic[$(this).parent().attr('id')];
                        $('.coffee-option').css('display', 'flex');
                        $('.coffee-option-img').attr('src', coffee['이미지']);
                        
                        // 옵션 설정하기
                        $.each(coffee['옵션'], function(opt_name, opt_list) {
                            $('#' + opt_name).html(make_radio_button(opt_name, opt_list));
                        });

                    });
                },
                error: function (response) {
                    alert('error');
                },
                complete : function() {}
            });
            
            $(document).mouseup(function (e){
                if(coffee_option.has(e.target).length==0) {
                    coffee_option.css('display', 'none'); 
                } 
            });

            
        });
    </script>
</asp:Content>
