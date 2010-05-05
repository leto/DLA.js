var Hump = (function($) {
  var hump = {
    Unit: function(fn) {
      var contents = fn.toString().match(/^[^\{]*{((.*\n*)*)}/m)[1];
      var fn = new Function("matchers", "specifications",
        "with (specifications) { with (matchers) { " + contents + " } }"
      );

      $(Hump).queue(function() {
        Hump.Specifications.context.push($('body > .describe'));
        fn.call(this, Hump.Matchers, Hump.Specifications);
        Hump.Specifications.context.pop();
        $(this).dequeue();
      });
    },

    Specifications: {
      context: [],

      describe: function(name, fn) {
        var describe = $('<li class="describe"></li>')
          .append($('<h1></h1>').text(name))
          .append('<ol class="befores"></ol>')
          .append('<ul class="its"></ul>')
          .append('<ul class="describes"></ul>')
          .append('<ol class="afters"></ol>');

        this.context.push(describe);
        fn.call();
        this.context.pop();

        this.context[this.context.length-1]
          .children('.describes')
            .append(describe);
      },

      it: function(name, fn) {
        if (fn == undefined) { fn = false; }
        var it = $('<li class="it"></li>')
          .append($('<h2></h2>').text(name))
          .data('humpunit.run', fn);

        this.context[this.context.length-1]
          .children('.its')
            .append(it);
      },

      before: function(fn) {
        var before = $('<li class="before"></li>')
          .data('humpunit.run', fn);

        this.context[this.context.length-1]
          .children('.befores')
            .append(before);
      },

      after: function(fn) {
        var after = $('<li class="after"></li>')
          .data('humpunit.run', fn);

        this.context[this.context.length-1]
          .children('.afters')
            .append(after);
      }
    }
  };

  $(hump).queue(function() { $(hump).trigger('loading') });
  $(function() {
    $('<div class="describe"></div>')
      .append('<h3 class="status"></h3>')
      .append('<ol class="befores"></ol>')
      .append('<ul class="describes"></ul>')
      .append('<ol class="afters"></ol>')
      .appendTo('body');

    $(hump).dequeue();
    $(hump).trigger('loaded');
  });
  return hump;
})(jQuery);
