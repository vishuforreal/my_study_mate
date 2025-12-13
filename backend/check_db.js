const mongoose = require('mongoose');

const MONGODB_URI = 'mongodb+srv://vishukumar:vishukumar@cluster0.mongodb.net/mystudymate';

mongoose.connect(MONGODB_URI)
  .then(async () => {
    console.log('Connected to MongoDB');
    
    const Category = require('./models/Category');
    const Note = require('./models/Note');
    
    console.log('\n=== CATEGORIES ===');
    const categories = await Category.find({});
    console.log('Total categories:', categories.length);
    categories.forEach(cat => {
      console.log(`- ${cat.name} (${cat.subcategories.length} subcategories)`);
    });
    
    console.log('\n=== NOTES ===');
    const notes = await Note.find({});
    console.log('Total notes:', notes.length);
    notes.forEach(note => {
      console.log(`- ${note.title} | Category: ${note.category} | Subject: ${note.subject}`);
    });
    
    process.exit(0);
  })
  .catch(err => {
    console.error('Error:', err.message);
    process.exit(1);
  });