(function($){

    var NAME = 'navDropdown';
    var DATA_KEY = 'bs.nav-dropdown';
    var EVENT_KEY = '.' + DATA_KEY;
    var DATA_API_KEY = '.data-api';
    var JQUERY_NO_CONFLICT = $.fn[NAME];

    var Event = {
        HIDE: 'hide' + EVENT_KEY,
        HIDDEN: 'hidden' + EVENT_KEY,
        SHOW: 'show' + EVENT_KEY,
        SHOWN: 'shown' + EVENT_KEY,
        CLICK: 'click' + EVENT_KEY,
        READY: 'ready' + EVENT_KEY,
        COLLAPSE: 'collapse' + EVENT_KEY,
        LOAD_DATA_API: 'ready' + EVENT_KEY + DATA_API_KEY,
        CLICK_DATA_API: 'click' + EVENT_KEY + DATA_API_KEY,
        RESIZE_DATA_API: 'resize' + EVENT_KEY + DATA_API_KEY,
        KEYDOWN_DATA_API: 'keydown' + EVENT_KEY + DATA_API_KEY,
        NAVBAR_COLLAPSE: 'collapse.bs.navbar-dropdown'
    };

    var Hotkeys = {
        ESC: 27,
        LEFT: 37,
        UP: 38,
        RIGHT: 39,
        DOWN: 40
    };

    var Breakpoints = {
        XS: 544,
        SM: 768,
        MD: 992,
        LG: 1200,
        XL: Infinity
    };

    var ClassName = {
        BACKDROP: 'dropdown-backdrop',
        DISABLED: 'disabled',
        OPEN: 'open',
        SM: 'nav-dropdown-sm'
    };

    var Selector = {
        BASE: '.nav-dropdown',
        DROPDOWN: '.dropdown',
        DROPDOWN_MENU: '.dropdown-menu',
        BACKDROP: '.' + ClassName.BACKDROP,
        DATA_BUTTON: '[data-button]',
        DATA_TOGGLE: '[data-toggle="dropdown-submenu"]',
        FORM_CHILD: '.dropdown form'
    };



    var $$ = (function(){

        function Item(elements, prevItem) {
            if (!('length' in elements)) elements = [elements];
            this.props = {};
            this.length = elements.length;
            if (prevItem) {
                this.prevItem = prevItem;
                $.extend(this.props, prevItem.props);
            }
            for (var i = 0; i < elements.length; i++) {
                this[i] = elements[i];
            }
        }

        Item.prototype.eq = function(index) {
            return new Item(this[index] ? this[index] : [], this);
        };

        Item.prototype.parent = function() {
            return new Item(
                
                $(this).map(function(){

                    var $$this = new Item(this);

                    if ($$this.is(':upper')) return null;

                    return $( $$this.is(':toggle') ? this.parentNode.parentNode : this )
                        .closest(Selector.DROPDOWN)
                        .find('>' + Selector.DATA_TOGGLE)[0];

                }),

                this

            );
        };

        Item.prototype.parents = function(selector) {
            var elements = $(this).map(function(){

                return (new Item(this)).is(':toggle') ? this.parentNode : this;

            }).parentsUntil(Selector.BASE, Selector.DROPDOWN);

            if (selector === ':upper') elements = elements.last();
                
            elements = elements.find('>' + Selector.DATA_TOGGLE);

            return new Item(elements, this);
        };

        Item.prototype.children = function(deepSearch) {

            var elements = [];

            $(this).each(function(){

                var $parent, $items, $$item = new Item(this);

                if ($$item.is(':root')) {
                    $parent = $(this);
                } else if ($$item.is(':toggle')) {
                    $parent = $(this).parent().find('>' + Selector.DROPDOWN_MENU);
                } else {
                    return;
                }

                if (deepSearch) {
                    $items = $parent.find('a');
                } else if ($$item.is(':root')) {
                    $items = $parent.find('>li>a');
                } else {
                    $items = $parent.find('>a, >' + Selector.DROPDOWN + '>a');
                }

                $items.each(function(){

                    if ((deepSearch && !this.offsetWidth && !this.offsetHeight)
                        || this.disabled || $(this).is(Selector.DATA_BUTTON) || $(this).hasClass(ClassName.DISABLED) || ~$.inArray(this, elements)) {
                        return;
                    }

                    elements.push(this);

                });

            });

            return new Item(elements, this);

        };

        Item.prototype.root = function() {
            return new Item(
                $(this).closest(Selector.BASE),
                this
            );
        };

        Item.prototype.jump = function(step) {
            step = step || 'next';
            
            if (!this.length) {
                return new Item([], this);
            }
            
            var children, $$item = this.eq(0);
            if (this.is(':flat') || $$item.is(':upper')) {
                children = $$item.root().children( this.is(':flat') );
            } else {
                children = $$item.parent().children();
            }

            var index = $.inArray(this[0], children);
            if (!children.length || !~index) {
                return new Item([], this);
            }

            if (step == 'next') {
                index += 1;
                if (index < children.length) {
                    return new Item(children[index], this);
                }
                step = 'first';
            } else if (step == 'prev') {
                index -= 1;
                if (index >= 0) {
                    return new Item(children[index], this);
                }
                step = 'last';
            }

            if (step == 'first') return new Item(children[0], this);
            if (step == 'last') return new Item(children[ children.length - 1 ], this);

            return new Item([], this);
        };

        Item.prototype.next = function() {
            return this.jump('next');
        };

        Item.prototype.prev = function() {
            return this.jump('prev');
        };

        Item.prototype.first = function() {
            return this.jump('first');
        };

        Item.prototype.last = function() {
            return this.jump('last');
        };

        Item.prototype.prop = function(name, value) {
            if (arguments.length) {
                if (arguments.length > 1) {
                    this.props[name] = value;
                    return this;
                }
                if (typeof arguments[0] == 'object') {
                    $.extend(this.props, arguments[0]);
                    return this;
                }
                return (name in this.props) ?
                    this.props[name] : null;
            }
            return $.extend({}, this.props);
        };

        Item.prototype.removeProp = function(name) {
            delete this.props[name];
            return this;
        };

        Item.prototype.is = function(selector) {
            var $this = $(this),
                selectors = (selector || '').split(/(?=[*#.\[:\s])/);
            
            while (selector = selectors.pop()){
            
                switch (selector){
                
                    case ':root':
                        if (!$this.is(Selector.BASE))
                            return false;
                        break;

                    case ':upper':
                        if (!$this.parent().parent().is(Selector.BASE))
                            return false;
                        break;

                    case ':opened':
                    case ':closed':
                        if ((selector == ':opened') != $this.parent().hasClass(ClassName.OPEN))
                            return false;
                    case ':toggle':
                        if (!$this.is(Selector.DATA_TOGGLE))
                            return false;
                        break;

                    default:
                        if (!this.props[selector])
                            return false;
                        break;

                }

            }

            return true;
        };

        Item.prototype.open = function() {
            if (this.is(':closed')) {
                this.click();
            }
            return this;
        };

        Item.prototype.close = function() {
            if (this.is(':opened')) {
                this.click();
            }
            return this;
        };

        Item.prototype.focus = function() {
            if (this.length) {
                this[0].focus();
            }
            return this;
        };

        Item.prototype.click = function() {
            if (this.length) {
                $(this[0]).trigger('click');
            }
            return this;
        }

        return function(element) {
            return new Item(element);
        };

    })();



    var NavDropdown = function(element){
        this._element = element;
        $(this._element).on(Event.CLICK, this.toggle);
    };

    NavDropdown.prototype.toggle = function(event) {        
        if (this.disabled || $(this).hasClass(ClassName.DISABLED)) {
            return false;
        }

        var $parent = $(this.parentNode);
        var isActive = $parent.hasClass(ClassName.OPEN);
        var isCollapsed = NavDropdown._isCollapsed( $(this).closest(Selector.BASE) );

        NavDropdown._clearMenus(
            $.Event('click', {
                target: this,
                data: {
                    toggles: isCollapsed ? [this] : null
                }
            })
        );

        if (isActive) {
            return false;
        }

        if ('ontouchstart' in document.documentElement
            && !$parent.closest(Selector.DROPDOWN + '.' + ClassName.OPEN).length) {
        
            // if mobile we use a backdrop because click events don't delegate
            var dropdown = document.createElement('div');
            dropdown.className = ClassName.BACKDROP;
            $(dropdown).insertBefore( $(this).closest(Selector.BASE) );
            $(dropdown).on('click', NavDropdown._clearMenus);

        }

        var relatedTarget = { relatedTarget: this };
        var showEvent = $.Event(Event.SHOW, relatedTarget);

        $parent.trigger(showEvent);

        if (showEvent.isDefaultPrevented()) {
            return false;
        }

        this.focus();
        this.setAttribute('aria-expanded', 'true');

        $parent.toggleClass(ClassName.OPEN);
        $parent.trigger( $.Event(Event.SHOWN, relatedTarget) );

        return false;
    };

    NavDropdown.prototype.dispose = function() {
        $.removeData(this._element, DATA_KEY);
        $(this._element).off(EVENT_KEY);
        this._element = null;
    };

    NavDropdown._clearMenus = function(event) {
        event = event || {};

        if (event.which === 3) {
            return;
        }

        var collapseEvent;
        var filter = function(){ return false; };

        if (event.target) {

            if (this === document) {

                if ( $(event.target).is('a:not([disabled], .' + ClassName.DISABLED +  ')') ) {
                    collapseEvent = $.Event(Event.COLLAPSE, { relatedTarget: event.target })
                } else  {

                    var $rootNode = (event.targetWrapper && $(event.targetWrapper).find(Selector.BASE)) || $(event.target).closest(Selector.BASE);

                    if (NavDropdown._isCollapsed($rootNode)) return;
                }

            } else {

                if ($(event.target).hasClass(ClassName.BACKDROP)) {
                    var $nextNode = $(event.target).next();
                    if ($nextNode.is(Selector.BASE) && NavDropdown._isCollapsed($nextNode)) {
                        return;
                    }
                }

            }

            if ($(event.target).is(Selector.DATA_TOGGLE)) {
                filter = $(event.target.parentNode).parents(Selector.DROPDOWN).find('>' + Selector.DATA_TOGGLE);
            } else {
                $(Selector.BACKDROP).remove();
            }

        }

        var toggles = (event.data && event.data.toggles && $(event.data.toggles).parent().find(Selector.DATA_TOGGLE)) || $.makeArray( $(Selector.DATA_TOGGLE).not(filter) );

        for (var i = 0; i < toggles.length; i++) {

            var parent = toggles[i].parentNode;
            var relatedTarget = { relatedTarget: toggles[i] };

            if (!$(parent).hasClass(ClassName.OPEN)) {
                continue;
            }

            if (event.type === 'click' &&
                (/input|textarea/i.test(event.target.tagName)) &&
                ($.contains(parent, event.target))) {
                continue;
            }

            var hideEvent = $.Event(Event.HIDE, relatedTarget);
            $(parent).trigger(hideEvent);
            if (hideEvent.isDefaultPrevented()) {
                continue;
            }

            toggles[i].setAttribute('aria-expanded', 'false');

            $(parent)
                .removeClass(ClassName.OPEN)
                .trigger( $.Event(Event.HIDDEN, relatedTarget) );
                
        }

        if (collapseEvent) {
            $(document).trigger(collapseEvent);
        }

    };

    // static
    NavDropdown._dataApiKeydownHandler = function(event) {

          if (/input|textarea/i.test(event.target.tagName)) {
            return;
          }

          // ????
          var found;
          for (var k in Hotkeys) {
            if (found = (Hotkeys[k] === event.which)) {
                break;
            }
          }
          if (!found) return;

          event.preventDefault();
          event.stopPropagation();

          if (event.which == Hotkeys.ESC) {

            if (NavDropdown._isCollapsed(this)) {
                return;
            }

            var toggle = $(event.target).parents(Selector.DROPDOWN + '.' + ClassName.OPEN)
                .last().find('>' + Selector.DATA_TOGGLE);
            NavDropdown._clearMenus();
            toggle.trigger('focus');
            return;

          }

          if (event.target.tagName != 'A') {
            return;
          }

          var $$item = $$(event.target);
          
          $$item.prop(':flat', NavDropdown._isCollapsed($$item.root()));

          if ($$item.is(':flat')){

            if (event.which === Hotkeys.DOWN || event.which === Hotkeys.UP) {

                $$item[ event.which === Hotkeys.UP ? 'prev' : 'next' ]().focus();

            } else if (event.which === Hotkeys.LEFT) {
                
                if ($$item.is(':opened')) {
                    $$item.close();
                } else {
                    $$item.parent().close().focus();
                }

            } else if (event.which === Hotkeys.RIGHT && $$item.is(':toggle')) {
                $$item.open();
            }

          } else if ($$item.is(':upper')) {
          
              if (event.which === Hotkeys.LEFT || event.which === Hotkeys.RIGHT) {

                $$item[event.which === Hotkeys.LEFT ? 'prev' : 'next']().focus().open();
                if ($$item.is(':toggle')) $$item.close();

              } else if ((event.which === Hotkeys.DOWN || event.which === Hotkeys.UP) && $$item.is(':toggle')) {

                $$item.children()[ event.which === Hotkeys.DOWN ? 'first' : 'last' ]().focus();

              }

          } else {

              if (event.which === Hotkeys.LEFT) {

                var $$parent = $$item.parent();
                
                if ($$parent.is(':upper')) {
                    $$parent.close().prev().focus().open();
                } else {
                    $$parent.focus().close();
                }

              } else if (event.which === Hotkeys.RIGHT) {
                
                var $$children = $$item.children();
                if ($$children.length) {
                    $$item.open();
                    $$children.first().focus();
                } else {
                    $$item.parents(':upper').close().next().focus().open();
                }

              } else if (event.which === Hotkeys.DOWN || event.which === Hotkeys.UP) {

                $$item[ event.which === Hotkeys.UP ? 'prev' : 'next' ]().focus();

              }

          }
          
    };

    // static
    NavDropdown._isCollapsed = function(rootNode) {
        var match;
        if (rootNode.length) rootNode = rootNode[0];
        return rootNode && (match = /navbar-toggleable-(xs|sm|md|lg|xl)/.exec(rootNode.className))
            && (window.innerWidth < Breakpoints[ match[1].toUpperCase() ]);
    };

    // static
    NavDropdown._dataApiResizeHandler = function() {

        $(Selector.BASE).each(function(){
            
            var isCollapsed = NavDropdown._isCollapsed(this);
            
            $(this).find(Selector.DROPDOWN).removeClass(ClassName.OPEN);
            $(this).find('[aria-expanded="true"]').attr('aria-expanded', 'false');

            var backdrop = $(Selector.BACKDROP)[0];
            if (backdrop) {
                backdrop.parentNode.removeChild(backdrop); // ???
            }

            if (isCollapsed == $(this).hasClass(ClassName.SM)) {
                return;
            }

            if (isCollapsed) {
                $(this).addClass(ClassName.SM);
            } else {
                $(this).removeClass(ClassName.SM);

                // $(this).removeClass(ClassName.SM + ' in'); /// ???
                // NavDropdown._clearMenus();
            }

        });
    };

    /**
     * ------------------------------------------------------------------------
     * jQuery
     * ------------------------------------------------------------------------
     */

    $.fn[NAME] = function(config) {
        return this.each(function(){
            
            var data  = $(this).data(DATA_KEY);

            if (!data) {
                $(this).data(DATA_KEY, (data = new NavDropdown(this)));
            }

            if (typeof config === 'string') {
                if (data[config] === undefined) {
                    throw new Error('No method named "' + config + '"');
                }
                data[config].call(this);
            }

        });
    };
    $.fn[NAME].noConflict = function() {
        $.fn[NAME] = JQUERY_NO_CONFLICT;
        return this;
    };
    $.fn[NAME].Constructor = NavDropdown;
    $.fn[NAME].$$ = $$;


    $(window)
        .on(Event.RESIZE_DATA_API + ' ' + Event.LOAD_DATA_API, NavDropdown._dataApiResizeHandler);

    $(document)
        .on(Event.KEYDOWN_DATA_API, Selector.BASE,  NavDropdown._dataApiKeydownHandler)
        .on(Event.NAVBAR_COLLAPSE, NavDropdown._clearMenus)
        .on(Event.CLICK_DATA_API, NavDropdown._clearMenus)
        .on(Event.CLICK_DATA_API, Selector.DATA_TOGGLE, NavDropdown.prototype.toggle)
        .on(Event.CLICK_DATA_API, Selector.FORM_CHILD, function(e){
            e.stopPropagation();
        });

    $(window)
       .trigger(Event.READY);


})(jQuery);