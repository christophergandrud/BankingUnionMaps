var width = 700,
    height = 1160;

var projection = d3.geo.mercator()
    .center([20, 39])
    .scale(800)
    .rotate([15, 0])
    .translate([width / 2, height / 2]);

var color = d3.scale.ordinal()
    .domain([0, 1, 2, 3])
    .range(["#fff", "#c6dbef", "#6baed6", "#3182bd"]);


var path = d3.geo.path()
    .projection(projection);

var svgMap = d3.select("#map")
    .append("svg")
    .attr("width", width)
    .attr("height", height);

d3.json("json/europeClean.json", function(error, europe) {
    d3.csv("csv/BankingUnionMembers.csv", function(error, Membership) {
        var rateById = {};
        Membership.forEach(function(d) {
            rateById[d.id] = d.membership;
        });

        var subunits = topojson.feature(europe, europe.objects.subunits);

        svgMap.append("path")
            .datum(subunits)
            .attr("d", path);

        svgMap.selectAll(".subunit")
            .data(topojson.feature(europe, europe.objects.subunits).features)
            .enter().append("path")
            .attr("d", path)
            .style("fill", function(d) {
                return color(rateById[d.id]);
            });
    });
});
