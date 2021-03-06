# Ecom [![Build Status](https://travis-ci.org/aguxez/ecom.svg?branch=master)](https://travis-ci.org/aguxez/ecom)

### Template to start building an Ecommerce on Elixir and Phoenix.

#### Done

1. Users context with password hashing using Argon2.
2. Users can login and logout using Guardian.
3. Users can register, using a simple client-side verification and one server-side.
4. Users get recognized between admin and normal.
5. Admin can add/delete/edit product.
6. Spanish and English supported based on Locale.
7. Support for Markdown.
8. Support for adding pictures to Product. (Locally for now)
9. Shopping cart added. Users can add, edit, remove products, when an unlogged user logs in, the items that are NOT in the user's db cart are added and the session cart is deleted.
10. Payments
11. Shipping (User addresses)
12. Orders

### Being worked ATM
**Nothing at the moment**

### TODO
1. SEO tags
2. Flexible configuration
3. Wishlist (Optional for now)

### Dev TODO
- [x] There's a bug where `Repo.preload/2` raises an ArgumentError on tests; specifically "cannot load `[]` as type :map for field `products` in schema Ecom.Accounts.Cart" but it works on dev.

- [x] Do proper cleanup when payment is made (Value state, Product quantity, etc...)

- [x] Add amount of order and order "receipt" to Admin dashboard once a payment is done.

- [ ] Do new incorporation of Paypal (Or any other payment gateway, honestly), right now it's being used as a client-side with a websockets solution for validation.

### Running

```sh
-> git clone https://github.com/aguxez/ecom.git
-> cd ecom
-> mix do deps.get, compile
-> cd apps/ecom
-> mix ecto.setup
-> cd ../ecom_web/assets
-> yarn
```

Add something to  `seeds.exs` and then `mix run priv/repo/seeds.exs`

`iex mix -S phx.server` and go to localhost:4000

### Notes:
#### Local uploads
For local uploads, the folder being used is `/var/www/uploads/product/image/`, if you want to remove this, edit `Ecom.Uploaders.Image.storage_dir/2` and the `Plug` serving these files on `endpoint.ex`.

#### Payment solution for this [commit](https://github.com/aguxez/ecom/commit/42d5ca76f69ef705113db8b04c36e5b7b997937b)
There was a lot to think here. I wanted to take the approach of just using a simple "Pay" button from PayPal that had information on inputs on the front-end, obviously this is a security flaw and I wanted to take care of that (At this exact moment I don't have access to a 'live' PayPal token, hence I couldn't just use their API). I used WebSockets for validating the information being sent, updating the amount and redirect URL accordingly, also I put an UUID on the session to check on the redirect URI so we can validate the order and place it on the admin panel; with the session approach we don't risk getting a GET request on the payments endpoint and processing an order which wasn't paid since we validate the UUID in the parameter. To remove this, edit:

1. `socket.js`
2. `payments_channel.ex`
3. `user_socket.ex`
4. `payments_controller.ex`
5. `index.html.eex` from the Payments folder in templates
6. `worker.ex` from the `Ecom` app.
7. `pay_id.ex` from the Plugs folder in the `EcomWeb` app.

#### `current_user/2`
It's a helper function from `EcomWeb.Helpers` imported in the Controllers and Views

#### Unable to encode value
When `Poison` throws an encoding error such as `unable to encode value {nil, "users"}`, it's because the Struct or whatever you're trying to encode has private data such as `__meta__`.

Solution: Add `@derive {Poison.Encoder, except: [:__meta__]}` or the field that has private data to the schema you're retrieving information from.

#### Using spread syntax with babel
`yarn add babel-plugin-transform-object-rest-spread --save-dev` then on `.brunch-config.js` on `plugins/babel`: `"plugins": ["transform-object-rest-spread"]`

#### Foundation 6 way to initialize JS.

`var Foundation = require('foundation-sites/dist/js/foundation');` then
```js
$(document).ready($ => {
  $(document).foundation();
})
```

#### Gettext
All configuration is given through `config :gettext, opts`, not `config :my_app, MyApp.Gettext`

#### Use SimpleMDE
As default text editor.

#### Image uploads
At the beginning they're handled locally, if you're planning to use a Cloud Storage Service, further configuration is required.

#### Attachments
Arc_ecto provides the `cast_attachments` function. The attachment should be casted only on that function and not on `cast`

#### regeneratorRuntime is not defined
Install `babel-plugin-transform-runtime` and add it to the plugins besides other common dependencies
