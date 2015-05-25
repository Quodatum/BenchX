declare variable $static external :="/static/benchx/";

<div class="container">
 <div id="loading" ng-show="hasPendingRequests()">
        <img src="{$static}ajax-loader.gif" />
    </div>
    <div class="container-fluid" ng-include="'{$static}templates/navbar.xhtml'">
    </div>
    
<div class="container">
      <div class="container-fluid" ng-include="'{$static}templates/navbar.xhtml'">
        </div>
      <div class="center-container">
        <ui-view class="view-animate" style="position:relative;">Loading...</ui-view>
        </div>
      <div growl="growl"/>
</div>
</div>
