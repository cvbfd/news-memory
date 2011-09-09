function submitCountry() {
    window.location = "/country/" + $("#nav_country").val();
}

function submitNewspaper() {
    window.location = "/newspaper/" + $("#nav_newspaper").val();
}

function submitDate() {
    if($("#nav_date").val() != "") {
        window.location = "/date/" + $("#nav_date").val().replace("/", "-").replace("/", "-");
    }
}

Date.format = 'mm/dd/yyyy';
$(document).ready(function() {
   $("a.cover").fancybox();
    $('#nav_date').datePicker(
        {
            startDate: '01/01/1970',
            endDate: (new Date()).asString()
        }
    );
});
