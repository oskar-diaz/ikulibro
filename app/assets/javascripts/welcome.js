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

  $(".news-toggle").on("click", function () {
    var $news = $(this).closest(".news");
    var isExpanded = $news.hasClass("is-expanded");
    var expandedLabel = $(this).data("expanded-label");
    var collapsedLabel = $(this).data("collapsed-label");

    $news.toggleClass("is-expanded");
    $(this).attr("aria-expanded", isExpanded ? "false" : "true");
    $(this).attr("aria-label", isExpanded ? collapsedLabel : expandedLabel);
  });

  $(document).on("click", ".featured-review-card__toggle", function () {
    var $button = $(this);
    var $card = $button.closest(".featured-review-card");
    var isExpanded = $card.hasClass("is-expanded");
    var expandedLabel = $button.data("expanded-label") || "Ver menos";
    var collapsedLabel = $button.data("collapsed-label") || "Ver más";
    var nextExpanded = !isExpanded;

    $card.toggleClass("is-expanded", nextExpanded);
    $button.attr("aria-expanded", nextExpanded ? "true" : "false");
    $button.attr("aria-label", nextExpanded ? expandedLabel : collapsedLabel);
  });

  $(document).on("click", ".featured-review-card__refresh", function (e) {
    e.preventDefault();

    var $button = $(this);
    if ($button.hasClass("is-loading")) {
      return;
    }

    var $card = $button.closest(".featured-review-card");
    var currentReviewId = $card.data("review-id");

    $button.addClass("is-loading").attr("aria-busy", "true");

    $.ajax({
      type: "GET",
      url: $button.attr("href"),
      dataType: "html",
      data: { exclude_review_id: currentReviewId },
    })
      .done(function (html) {
        if (!html || !$.trim(html)) {
          return;
        }

        var $newCard = $(html);
        if ($newCard.length) {
          $card.replaceWith($newCard);
        }
      })
      .always(function () {
        $button.removeClass("is-loading").removeAttr("aria-busy");
      });
  });

  setInterval(function () {
    $("#reacciones").removeClass("bounceInRight").toggleClass("tada");
  }, 5000);


});
