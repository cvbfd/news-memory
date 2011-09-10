$(function () {
    $("#edit_newspaper_select").change(function() {
        var newspaper = newspapers[$(this).val()];
        if (newspaper != null) {
            $("#edit_newspaper_name").val(newspaper.name);
            $("#edit_newspaper_country").val(newspaper.country);
            $("#edit_newspaper_uri").val(newspaper.uri);
            $("#edit_newspaper_wikipedia_uri").val(newspaper.wikipedia_uri);
        }
    });
});