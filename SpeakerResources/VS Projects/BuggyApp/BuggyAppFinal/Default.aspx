<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="BuggyAppFinal._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

<div class="jumbotron">
    <h1>Buggy App</h1>
    <p class="lead">Welcome to the wonderful world of ASP.NET troubleshooting</p>
    <p><a href="http://asp.net" class="btn btn-primary btn-lg">Learn more &raquo;</a></p>
</div>

  <div class="row">
    <div class="col-md-4">
        <h2>Performance Issues</h2>
        <p>This one calls an external API which might be slow...</p>
        <p><asp:HyperLink runat="server" Text="Cross Fingers!" NavigateUrl="/Categories.aspx" /></p>
    </div>
    <div class="col-md-4">
        <h2>What about 500 errors?</h2>
        <p>Just click the link below</p>
        <p><asp:HyperLink runat="server" Text="Crash it!" NavigateUrl="/Products.aspx" /></p>
    </div>
    <div class="col-md-4">
        <h2>4xx errors?</h2>
        <p>Click this link to cause a 404 error :)</p>
        <p><asp:HyperLink runat="server" Text="Go Nowhere..." NavigateUrl="/ProductList.aspx" /></p>
    </div>
</div>

</asp:Content>
