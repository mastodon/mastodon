# Folder Structure


## Packs a.k.a webpack entries

"Packs" is a special directory made only for webpack entry files so don't put anything
here that you don't want to link in your views.


## Source

You can put your app source under `app/javascript` folder or whatever you have configured
in `config/webpacker.yml`.


## Example

Let's say you're building a calendar app. Your JS app structure could look like this:

```js
// app/javascript/packs/calendar.js

import 'calendar'
```

```
app/javascript/calendar/index.js // gets loaded by import 'calendar'
app/javascript/calendar/components/grid.jsx
app/javascript/calendar/styles/grid.sass
app/javascript/calendar/models/month.js
```

```erb
<%# app/views/layouts/application.html.erb %>

<%= javascript_pack_tag 'calendar' %>
<%= stylesheet_pack_tag 'calendar' %>
```

But it could also look a million other ways.


## Namespacing

You can also namespace your packs using directories similar to a Rails app.

```
app/javascript/packs/admin/orders.js
app/javascript/packs/shop/orders.js
```

and reference them in your views like this:

```erb
<%# app/views/admin/orders/index.html.erb %>

<%= javascript_pack_tag 'admin/orders' %>
```

and

```erb
<%# app/views/shop/orders/index.html.erb %>

<%= javascript_pack_tag 'shop/orders' %>
```
