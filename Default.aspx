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
                    <div class="switch-field">
                        <input type="radio" id="radio-hot" name="hot-ice" value="hot" checked/>
                        <label for="radio-hot">HOT</label>
                        <input type="radio" id="radio-ice" name="hot-ice" value="ice"/>
                        <label for="radio-ice">ICE</label>
                    </div>
                </li>
                <li>
                    <span>사이즈</span>
                    <div class="switch-field">
                        <input type="radio" id="radio-A" name="ABC" value="A" checked/>
                        <label for="radio-A">A</label>
                        <input type="radio" id="radio-B" name="ABC" value="B"/>
                        <label for="radio-B">B</label>
                        <input type="radio" id="radio-C" name="ABC" value="C"/>
                        <label for="radio-C">C</label>
                    </div>
                </li>
                <li>
                    <span>샷 추가</span>
                </li>

            </div>
        </div>
    </div>

    <script>
        

        
        $(document).ready(function() {
            var coffee_option = $('.coffee-option');
            var obj = {cmd : "get_coffees", data:""}
            // 커피 목록 받아오기
            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                url: '<%= ResolveUrl("Default.aspx/RequestData") %>',
                data: JSON.stringify(obj),
                async: false,
                success: function (response) {
                    var data = JSON.parse(response.d)["data"];
                    // 커피 목록 갱신하기
                    $.each(data, function(key, value) {
                        var coffee = $('#coffee-template').clone();
                        coffee.css('display', 'block');
                        coffee.children('span').text(key);
                        coffee.children('.coffee-box').children('img').attr('src', value["이미지"]);
                        $('.coffee-list').append(coffee);
                    });
                },
                error: function (response) {
                    alert("error!");
                },
                complete : function() {
                    //alert("complete!");
                }
            });
            
            $(document).mouseup(function (e){
                if(coffee_option.has(e.target).length==0) {
                    coffee_option.css('display', 'none'); 
                } 
            });

            $('.coffee-box').click(function() {
                $('.coffee-option').css('display', 'flex');
                $('.coffee-option-img').attr('src', $(this).children('img').attr('src'));

            });
        });
    </script>
</asp:Content>
