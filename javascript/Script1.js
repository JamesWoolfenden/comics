// JavaScript source code

function prep()
{
        // prepare the data
        var source = {
            datafields: [{ name: 'date' }, { name: 'quantity' }, { name: 'description' }],
            root: "orders",
            record: "order",
            datatype: "xml",
            url: './jqwidgets/demos/sampledata/xmldata.xml'
        }
        var dataAdapter = new $.jqx.dataAdapter(source);
			
        // prepare jqxChart settings
        var settings = {
            title: "Orders for January - May",
            showLegend: true,
            enableAnimations: true,
            source: dataAdapter,
            xAxis: {
                dataField: 'date',
                formatFunction: function (value) {
                    var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                    return months[new Date(value).getMonth()];
                },
                showGridLines: true
            },
            colorScheme: 'scheme04',
            seriesGroups: [{
                type: 'column',
                valueAxis: {
                    displayValueAxis: true,
                    axisSize: 'auto',
                    tickMarksColor: '#888888'
                },
                series: [{ dataField: 'quantity', displayText: 'Quantity' }]
            }]
        };
			
        // setup the chart
        $('#chartContainer').jqxChart(settings);
}

prep();