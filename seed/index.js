import express from 'express';
import db from './config/db.js'

import mongoose from 'mongoose';
const { Schema } = mongoose;

const app = express();
db(); // connection to database

var authors = [];
var genres  = [];
var books   = [];

// Define the schema for an author
var AuthorSchema = new Schema(
    {
      first_name: {type: String, required: true, max: 100},
      family_name: {type: String, required: true, max: 100},
      date_of_birth: {type: Date},
      date_of_death: {type: Date},
    }
  );

  var BookSchema = new Schema(
    {
      title: {type: String, required: true},
      summary: {type: String, required: true},
      isbn: {type: String, required: true},
      author: [{type: Schema.Types.ObjectId, ref: 'Author', required: true}],
      genre: [{type: Schema.Types.ObjectId, ref: 'Genre'}]
    }
  );

  var BookInstanceSchema = new Schema(
    {
      book: { type: Schema.Types.ObjectId, ref: 'Book', required: true }, //reference to the associated book
      imprint: {type: String, required: true},
      status: {type: String, required: true, enum: ['Available', 'Maintenance', 'Loaned', 'Reserved'], default: 'Maintenance'},
      due_back: {type: Date, default: Date.now}
    }
  );

  var GenreSchema = new Schema(
    {
      name: {type: String, required: true}
    }
  );

// Create a model for the user schema
const Author = mongoose.model('Author', AuthorSchema);
const authorDoc = new Author();
const Book = mongoose.model('Book', BookSchema);
const BookInstance = mongoose.model('BookInstance',BookInstanceSchema);
const Genre = mongoose.model('Genre', GenreSchema);

// code to seed database for local library

async function authorCreate(authors, first_name, family_name, d_birth, d_death) {
  if (d_birth == false) d_birth = null;
  if (d_death == false)  d_death = null;  
  let newAuthor = new Author({
    first_name: first_name,
    family_name: family_name,
    date_of_birth: d_birth,
    date_of_death: d_death
  });
  await newAuthor.save()
   .then( 
    user =>{console.log('Author created:', user._id);authors.push(user._id);console.log(authors)
    })
   .catch(err => console.error(err));
}

async function genreCreate(genres, name) {
  let newGenre = new Genre({ name: name });
  await newGenre.save()
  .then( user =>{console.log('Genre created:', user._id);genres.push(user._id);console.log(genres)})
  .catch(err => console.error(err));
}

async function bookCreate(books, title, summary, isbn , authors, genres) {
  if (genres == false) genres = null;
  let newBook = new Book({
    title: title,
    summary: summary,
    author: authors,
    isbn: isbn,
    genre: genres
  });
  await newBook.save()
  .then( user =>{console.log('Book created:', user._id);books.push(user._id);console.log(books)})
  .catch(err => console.error(err));
}

async function bookInstanceCreate(book, imprint, status, due_back ) {
  if (due_back == false) due_back = null;
  if (status == false) status = 'Maintenance';
  let newBookInstance = new BookInstance ({
    book: book,
    imprint: imprint,
    status: status,
    due_back: due_back,
  });
  await newBookInstance.save()
  .then( user =>{console.log('Book Instance created:', user._id);})
  .catch(err => console.error(err));
}

// seeding data
async function seed(){

await Book.collection.drop().then(() => { }).catch(() => { console.log('error dropping book collection') });  
await Author.collection.drop().then(() => { }).catch(() => { console.log('error dropping author collection') }); 
await BookInstance.collection.drop().then(() => { }).catch(() => { console.log('error dropping bookinstance collection')}); 
await Genre.collection.drop().then(() => { }).catch(() => { console.log('error dropping genre collection') }); 

await authorCreate(authors,"Patrick", "Rothfuss", "1973-06-06", false);
await authorCreate(authors,"Ben", "Bova", "1932-11-8", false);
await authorCreate(authors,"Isaac", "Asimov", "1920-01-02", "1992-04-06");
await authorCreate(authors,"Bob", "Billings", false, false);
await authorCreate(authors,"Jim", "Jones", "1971-12-16", false);

await genreCreate(genres, "Fantasy");
await genreCreate(genres, "Science Fiction");
await genreCreate(genres, "French Poetry");

await bookCreate(
  books,
  "The Name of the Wind (The Kingkiller Chronicle, #1)",
  "I have stolen princesses back from sleeping barrow kings. I burned down the town of Trebon. I have spent the night with Felurian and left with both my sanity and my life. I was expelled from the University at a younger age than most people are allowed in. I tread paths by moonlight that others fear to speak of during day. I have talked to Gods, loved women, and written songs that make the minstrels weep.",
  "9781473211896",
  [authors[0]],
  [genres[0]]
);

await bookCreate(
  books,
  "The Wise Man's Fear (The Kingkiller Chronicle, #2)",
  "Picking up the tale of Kvothe Kingkiller once again, we follow him into exile, into political intrigue, courtship, adventure, love and magic... and further along the path that has turned Kvothe, the mightiest magician of his age, a legend in his own time, into Kote, the unassuming pub landlord.",
  "9788401352836",
  [authors[0]],
  [genres[0]]
);

await bookCreate(
  books,
  "The Slow Regard of Silent Things (Kingkiller Chronicle)",
  "Deep below the University, there is a dark place. Few people know of it: a broken web of ancient passageways and abandoned rooms. A young woman lives there, tucked among the sprawling tunnels of the Underthing, snug in the heart of this forgotten place.",
  "9780756411336",
  [authors[0]],
  [genres[0]]
);

await bookCreate(
  books,
  "Apes and Angels",
  "Humankind headed out to the stars not for conquest, nor exploration, nor even for curiosity. Humans went to the stars in a desperate crusade to save intelligent life wherever they found it. A wave of death is spreading through the Milky Way galaxy, an expanding sphere of lethal gamma ...",
  "9780765379528",
  [authors[1]],
  [genres[1]]
);

await bookCreate(
  books,
  "Death Wave",
  "In Ben Bova's previous novel New Earth, Jordan Kell led the first human mission beyond the solar system. They discovered the ruins of an ancient alien civilization. But one alien AI survived, and it revealed to Jordan Kell that an explosion in the black hole at the heart of the Milky Way galaxy has created a wave of deadly radiation, expanding out from the core toward Earth. Unless the human race acts to save itself, all life on Earth will be wiped out...",
  "9780765379504",
  [authors[1]],
  [genres[1]]
);

await bookCreate(
  books,
  "Test Book 1",
  "Summary of test book 1", 
  "ISBN111111", 
  [authors[4],authors[3]], 
  [genres[0],genres[1]]
);

  await bookCreate(
  books,
  "Test Book 2",
  "Summary of test book 2",
  "ISBN222222",
  [authors[4]],
  [genres[0],genres[1]]
);

await bookInstanceCreate(books[0], "London Gollancz, 2014.", "Available",false );
await bookInstanceCreate(books[1], " Gollancz, 2011.",  "Loaned","2020-06-06");
await bookInstanceCreate(books[2], " Gollancz, 2015.", false, false);
await bookInstanceCreate( 
  books[3],
  "New York Tom Doherty Associates, 2016.",
  "Available",
  false,
);
await bookInstanceCreate(
  books[3],
  "New York Tom Doherty Associates, 2016.",
  "Available",
  false,
);
await bookInstanceCreate(
  books[3],
  "New York Tom Doherty Associates, 2016.",
  "Available",
  false
);
await bookInstanceCreate(
  books[4],
  "New York, NY Tom Doherty Associates, LLC, 2015.",
  "Available",
  false
  
);
await bookInstanceCreate(
  books[4],
  "New York, NY Tom Doherty Associates, LLC, 2015.",
  "Maintenance",
  false,
);
await bookInstanceCreate(
  books[4],
  "New York, NY Tom Doherty Associates, LLC, 2015.",
  "Loaned",
  false
);
await bookInstanceCreate(books[0], "Imprint XXX2", false, false);
await bookInstanceCreate(books[1], "Imprint XXX3", false, false);

}

seed();

app.listen(3000, () => {
    console.log('Server started on port 3000');
});
