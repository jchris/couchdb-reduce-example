function (keys, values, rereduce) {
  // This computes the standard deviation of the mapped results
  var stdDeviation=0.0;
  var count=0;
  var total=0.0;
  var sqrTotal=0.0;

  if (!rereduce) {
    // This is the reduce phase, we are reducing over emitted values from
    // the map functions.
    for(var i in values) {
      total = total + values[i];
      sqrTotal = sqrTotal + (values[i] * values[i]);
    }
    count = values.length;
  }
  else {
    // This is the rereduce phase, we are re-reducing previosuly
    // reduced values.
    for(var i in values) {
      count = count + values[i].count;
      total = total + values[i].total;
      sqrTotal = sqrTotal + values[i].sqrTotal;
    }
  }

  var variance =  (sqrTotal - ((total * total)/count)) / count;
  stdDeviation = Math.sqrt(variance);

  // the reduce result. It contains enough information to be rereduced
  // with other reduce results.
  return {"stdDeviation":stdDeviation,"count":count,
  "total":total,"sqrTotal":sqrTotal};
};