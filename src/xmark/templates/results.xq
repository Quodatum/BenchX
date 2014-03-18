declare  variable $results external;
declare  variable $sources external;
declare  variable $avg external;
<div>
    <h2>Results (ms)</h2>
    <div> Avg: {$avg}</div>
    <table class="table table-striped table-responsive table-condensed">
        <thead>{$sources}</thead>
        <tbody><tr>{$results}</tr></tbody>
    </table>
</div>

 