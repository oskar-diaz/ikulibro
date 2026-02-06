$(function () {
  $("#send").on("click", function () {
    if (!$("#nombre").val()) {
      alertify.error("Hombre, digo yo que el nombre por lo menos ya me dirás, ¿no?");
      return;
    }

    var csrfToken = $('meta[name="csrf-token"]').attr("content");

    $.ajax({
      type: "PUT",
      url: "/contacto",
      data: {
        name: $("#nombre").val(),
        email: $("#email").val(),
        comments: $("#comments").val(),
      },
      headers: {
        "X-CSRF-Token": csrfToken,
      },
      complete: function (data) {
        $("#pedirLibro").foundation("reveal", "close");
        alertify.alert(data.responseText);
      },
    });
  });

  $("#aqui").hover(
    function () {
      $(this).addClass("shake");
    },
    function () {
      $(this).removeClass("shake");
    }
  );

  $("#pedir").on("click", function () {
    window.scrollTo({ top: 0, left: 0, behavior: "smooth" });
  });

  setInterval(function () {
    $("#reacciones").removeClass("bounceInRight").toggleClass("tada");
  }, 5000);


});
