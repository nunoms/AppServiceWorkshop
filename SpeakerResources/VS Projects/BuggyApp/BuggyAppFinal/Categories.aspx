<%@ Page Language="C#" Title="Categories" AutoEventWireup="true" CodeBehind="Categories.aspx.cs" Inherits="BuggyAppFinal.Categories"  MasterPageFile="~/Site.Master"%>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <h2><%: Title %></h2>
    <h3>Choose One:</h3>
    <p>
        <asp:ListView runat="server" ID="myList">
        <ItemTemplate>
            <h4><%# Container.DataItem %></h4>
        </ItemTemplate>
       </asp:ListView> 

    </p>
</asp:Content>
