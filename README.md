# Ecom

### Template to start building an Ecommerce on Elixir and Phoenix.

### Done

1. Users context with password hashing using Argon2.
2. Users can login and logout using Guardian.
3. Users can register, using a simple client-side verification and one server-side.
4. Users get recognized between admin and normal.
5. Admin can add/delete/edit product.
6. Spanish and English supported based on Locale.
7. Support for Markdown.
8. Support for adding pictures to Product.
9. Shopping cart added. Users can add, edit, remove products, when an unlogged user logs in, the items that are NOT in the user's db cart are added and the session cart is deleted.

### Being worked ATM
**Payments**

### TODO
- [ ] Shipping
- [ ] Categories
- [ ] SEO tags
- [ ] Wishlist
- [ ] Flexible configuration

### Dev TODO
- [ ] There's a bug where `Repo.preload/2` raises an ArgumentError on tests; specifically "cannot load `[]` as type :map for field `products` in schema Ecom.Accounts.Cart" but it works on dev.

### Running

```sh
-> git clone https://github.com/aguxez/ecom.git
-> cd ecom
-> mix do deps.get, compile
-> cd apps/ecom
-> mix ecto.setup
-> cd assets
-> yarn
```

Add something to  `seeds.exs` file and then `mix run priv/repo/seeds.exs`

`iex mix -S phx.server` and go to localhost:4000

### Notes:
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
