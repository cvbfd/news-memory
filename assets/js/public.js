function submitCountry() {
    window.location = "/country/" + $("#nav_country").val();
}

function submitNewspaper() {
    window.location = "/newspaper/" + $("#nav_newspaper").val();
}

function submitDate() {
    if ($("#nav_date").val() != "") {
        window.location = "/date/" + $("#nav_date").val().replace("/", "-").replace("/", "-");
    }
}

function formatTitle(title, currentArray, currentIndex, currentOpts) {
    return "<div class='zoom'>" + $(currentArray[currentIndex]).attr('formattedtitle') + "</div>";
}

Date.format = 'mm/dd/yyyy';


var currentPage = 1;
var fancyBoxParams = {
    titlePosition: 'inside',
    titleFormat: formatTitle,
    width: 1024,
    height: 720,
    autoScale: false,
    hideOnContentClick: true
};

$(document).ready(function() {
    $('header').bigtext({
        childSelector: '> h1'
    });
    $("a.cover").fancybox(fancyBoxParams);
    $('#nav_date').datePicker(
        {
            startDate: minDate,
            endDate: (new Date()).asString()
        }
    );
    $("#more a").click(function() {
        $.getJSON(morePath + currentPage, function(data) {
            var content = $("#content");
            $.each(data, function(index, s) {
                var date = new Date(s.date * 1000);
                var stringDate = date.getDay() + "/" + date.getMonth() + "/" + date.getFullYear();
                var stringTime = date.getHours() + ":" + date.getMinutes() + "/" + date.getSeconds();
                var stringDateLink = date.getDay() + "-" + date.getMonth() + "-" + date.getFullYear();
                $(
                    '<a class="cover"' + 'title="' + s.name + " – " + stringDate + " " + stringTime + '"' +
                        'formattedTitle="<a href=\'/newspaper/' + s.newspaper + '\'>' + s.name + '</a> – <a href=\'/date/' + stringDateLink + '\'>' + stringDate + ' ' + stringTime + '</a>"' +
                        'href="' + s.snapshot + '">' +
                        '<img src="' + s.small_snapshot + '" title="' + s.name + ' – ' + stringDate + ' ' + stringTime + '">' +
                        '</a>'
                ).appendTo(content).fancybox(fancyBoxParams);
            });

            currentPage++;

            if (data.length < 100) {
                $("#more").hide();
            }
        });
        return false;
    });
});
