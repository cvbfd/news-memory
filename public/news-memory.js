function submitCountry() {
    window.location = "/country/" + $("#nav_country").val();
}

function submitNewspaper() {
    window.location = "/newspaper/" + $("#nav_newspaper").val();
}

$(document).ready(function() {
   $("a.cover").fancybox();
});
