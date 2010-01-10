var DisableSubmit = Class.create({
  timer : 6,

  initialize : function(submit_elements, timer){
    this.submit_elements = submit_elements;
    this.timer = timer;
    Event.observe(window, 'load', this.set_event.bindAsEventListener(this), false);
    Event.observe(window, 'unload', this.set_enable.bindAsEventListener(this), false);
  },

  set_event : function(){
    this.submit_elements.each(function(elem){
      Event.observe(elem, 'click', this.set_disable.bindAsEventListener(this), false);
    }.bind(this));
  },

  set_enable : function(){
    this.submit_elements.invoke('enable')
  },
    
  set_disable : function(event){
    var elem = event.element();
    var on_click_func = elem.onclick;
    elem.onclick = '';
    (function(){elem.disable()}).delay(0.001)
    if(on_click_func){ on_click_func.delay(0.002) }
    (function(){elem.enable()}).delay(this.timer)
  }
});
