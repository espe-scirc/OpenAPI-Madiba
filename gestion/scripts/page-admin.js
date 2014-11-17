$(function() {
    $("#cn").autocomplete({
	source: "scripts/recherche.pl",
	minLength: 3,
	select: function(event, ui) {
		$('#uid').val(ui.item.uid);
		$('#cn').val(ui.item);
                }

    });
});

function popupinfo(data) {
	$(data).dialog({modal:true, width:500, open: function(event, ui){
		var $this = $(this);
		setTimeout(function(){$this.dialog('close')}, 5000);
    }, close: function (event, ui) { window.location.reload() }});;
}
	

$(function(){
	$('a[name=confirm]').click(function(){
		$.get($(this).attr('href'), popupinfo);
		return false;
	});
});

$(function(){
  $('form[name=confirm]').submit(function(){
    $.post($(this).attr('action'), $(this).serialize(), popupinfo, "html");
    return false;
  });
}); 

$(function(){
  $('form[name=supgestion]').submit(function(){
	  var formencours = $(this);
	      $("<div>Etes-vous sur de vouloir supprimer "+this.elements['cn_sup'].value+" ?</div>").dialog({
		      title: 'Confirmation',
        buttons: {
            "Ok": function() {
                $(this).dialog("close");
                $.post(formencours.attr('action'), formencours.serialize(), popupinfo, "html");
			}
            ,
            "Cancel": function() {
                $(this).dialog("close");
            }
        }
    });
    return false;

});
});