// Set the dimensions of the canvas / graph
var margin = {top: 30, right: 20, bottom: 30, left: 100},
    width = 700 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

// Parse the year / time
var parseDate = d3.time.format("%b %Y").parse;

// Set the ranges
var x = d3.time.scale().range([0, width]);
var y = d3.scale.linear().range([height, 0]);

// Define the axes
var xAxis = d3.svg.axis().scale(x)
    .orient("bottom").ticks(5);

var yAxis = d3.svg.axis().scale(y)
    .orient("left").ticks(5);

// Define the line
var priceline = d3.svg.line()
    .x(function(d) { return x(d.year); })
    .y(function(d) { return y(d.credit); });

// Adds the svg canvas
var svg = d3.select("body")
    .append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
    .append("g")
        .attr("transform",
              "translate(" + margin.left + "," + margin.top + ")");

// Get the data
d3.csv("csv/WorldBankData_noNA.csv", function(error, data) {
    data.forEach(function(d) {
        d.year = parseDate(d.year);
        d.credit = +d.credit;
    });

    // Scale the range of the data
    x.domain(d3.extent(data, function(d) { return d.year; }));
    y.domain([0, d3.max(data, function(d) { return d.credit; })]);

    // Nest the entries by country
    var dataNest = d3.nest()
        .key(function(d) {return d.country;})
        .entries(data);
        console.log("Data", dataNest);

    // Loop through each country / key
    dataNest.forEach(function(d) {
        var six = d.values[6];
        var position = six.credit;
        console.log("Selected Value", position);

        svg.append("path")
            .attr("class", "line")
            .attr("d", priceline(d.values))
            .style("stroke-opacity", 0.2)
            .style("stroke-width", 1)
            .on("mouseover", mouseover)
            .on("mouseout", mouseout)
        ;
        svg.append("text")
            .attr("class", "country-label")
            .attr("x", 0)
            .attr("y", y(position))
            .style("opacity", 0.5)
            .text(d.key)
            .on("mouseover", mouseover);

        function mouseover(){
            d3.select(this)
                .style("stroke-opacity", 1)
                .style("stroke-width", 10);
                d3.select(this).select("text")
                .style("font-opeacity", 1);
            }
        function mouseout(){
            d3.select(this)
                .transition().duration(750)
                .style("stroke-opacity", 0.2)
                .style("stroke-width", 1);
        }
    });

    // Add the X Axis
    svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis);

    // Add Y Axis label
    svg.append("g")
        .attr("class", "y axis")
        .call(yAxis)
        .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", "-4em")
        .style("text-anchor", "end")
        .style("font-size", 15)
        .text("Domestic Credit Provided by the Financial Sector");

});
