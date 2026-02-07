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

  var setupRandomHover = function ($btn) {
    var $variants = $btn.find(".icon-variant");
    if ($variants.length === 0) {
      return;
    }

    var setRandomVariant = function () {
      var prevIdx = $btn.data("variantIndex");
      var idx = Math.floor(Math.random() * $variants.length);
      if ($variants.length > 1) {
        while (idx === prevIdx) {
          idx = Math.floor(Math.random() * $variants.length);
        }
      }
      $variants.removeClass("active");
      $variants.eq(idx).addClass("active");
      $btn.addClass("show-variant");
      $btn.data("variantIndex", idx);
    };

    setRandomVariant();

    $btn.on("mouseenter", function () {
      setRandomVariant();
      $btn.addClass("hovering");
    });

    $btn.on("mouseleave", function () {
      $btn.removeClass("hovering");
    });
  };

  $(".amazon-btn.random-hover").each(function () {
    setupRandomHover($(this));
  });

  $(".amazon-btn.disabled").on("click", function (e) {
    e.preventDefault();
  });

  setInterval(function () {
    $("#reacciones").removeClass("bounceInRight").toggleClass("tada");
  }, 5000);


});
