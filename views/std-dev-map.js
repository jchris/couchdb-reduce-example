function(doc) {
  if (doc.time && doc.sensor && doc.value) {
    emit([doc.sensor, doc.time], doc.value);    
  }
};