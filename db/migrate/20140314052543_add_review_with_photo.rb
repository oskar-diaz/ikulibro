class AddReviewWithPhoto < ActiveRecord::Migration
  def change
    rev = Review.create(name: "Irene Mateo", review: "toc toc
siento interrumpir!
verá, después de llevar cinco horas estudiando como una loca, uno de mis gremlins okupa roba-bolis me ha dado una idea peregrina (ya era hora de que contribuyese en algo, despues de ir escondiendome varios bolis, no se cuantas gomas y un coletero) para animarle (de forma absurda) despues del palo con el cartero.
Le situo.
Me aburrí y me fuí a lisboa cinco dias, yo, mi mochila y su libro.
Siempre llevo un libro en mis viajes en solitario, pero desde que en Paris me largaron un discurso del que no entendí gran cosa pero cuyo mensaje estaba claro después de llevar dos horas ocupando una mesa, sin haber tocado el plato, absorta en Patrick Rothfuss (pero que quede constancia de que no fue culpa mia, es que el señor Rothfuss hace muy bien su trabajo!) decidí que a partir de entonces llevaria libros mas ligeritos, y si era de relatos cortos, mejor que mejor.
Asi que la vispera del viaje, se me fueron los ojos hacia su libro, le hice un chubasquero por las posibles lluvias (que al final alli casi fueron diluvios refresca cuestas que estuvieron genial) y lo llevé conmigo.
Por los motivos climaticos antes referidos, solo lo saqué en las comidas y una charla via whassap con una amiga durante diferentes días dió como resultado estas tres fotos (soy una negada con la camara, aunque sea tan simple como la de mi movil, asi que la calidad y todo lo que hace estetica una foto brilla por su ausencia, pero...pensé que igual le hacia ilusión, además de hacerle sangrar los ojos, ¡pero eso es un efecto secundario mas o menos sobrellevable!)
Resumiendo, su libro ha viajado a Lisboa y hecho turismo gastronomico ^^
Espero que al menos le haga gracia ^^'
Un saludo!!!")

  Image.create(review_id: rev.id, url: "https://s3-ap-northeast-1.amazonaws.com/ikulibro/DSCI4182.JPG")
  Image.create(review_id: rev.id, url: "https://s3-ap-northeast-1.amazonaws.com/ikulibro/DSCI4399.JPG")
  Image.create(review_id: rev.id, url: "https://s3-ap-northeast-1.amazonaws.com/ikulibro/DSCI4444.JPG")
  end
end
