var run = {
  a: function(){
    // more changes
    return 1;
  },

  b: function(x){
    var y;

    if(x === 0) (y = x === -1 ? 1 : 0);
    if(x > 0) y = 2;

    return y;
  },

  c: function(x){
    var zero = 0;
    var one = 1;

    var y = x > zero ? one : zero;

    return y;
  },

  d: function(){
    var one = 1;
    return 1;
  },

  e: function(){
    return 'blah';
  },

  f: function(){
    return 'untested';
  }
};

module.exports = run;
