$ ->
  $('#send').click ->
    if !$('#nombre').val() || !$('#email').val()
      alertify.error('Hombre, digo yo que el nombre y el email por lo menos ya me dirás, ¿no?')
    else
      $.ajax
        type: 'POST'
        url: '/contacto'
        data:
          _method: "put"
          name: $('#nombre').val()
          email: $('#email').val()
          address: $('#address').val()
          comments: $('#comments').val()
        complete: (data) ->
          $('#pedirLibro').foundation('reveal', 'close')
          alertify.alert(data.responseText)

  $("#pedir").hover (->
    $(this).addClass('rubberBand')
  ), ->
    $(this).removeClass('rubberBand')
  $('#aqui').hover (->
    $(this).addClass('shake')
    ), ->
    $(this).removeClass('shake')

  setInterval(->
    $('#reacciones').removeClass('bounceInRight').toggleClass('tada')
  , 5000)
