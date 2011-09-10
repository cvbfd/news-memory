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
    return "<div class='zoom'>" +  $(currentArray[currentIndex]).attr('formattedtitle') + "</div>";
}
Date.format = 'mm/dd/yyyy';
$(document).ready(function() {
    $("a.cover").fancybox(
        {
            titlePosition: 'inside',
            titleFormat: formatTitle,
            width: 1024,
            height: 720,
            autoScale: false,
            hideOnContentClick: true
        }
    );
    $('#nav_date').datePicker(
        {
            startDate: minDate,
            endDate: (new Date()).asString()
        }
    );
});
