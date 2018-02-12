# Ecom

## Template to start building an Ecommerce on Elixir, Phoenix and React.

### Done

1. Users context with password hashing using Argon2.
2. Users can login and logout using Guardian.
3. Users can register, using a simple client-side verification and one server-side.
4. Users get recognized between admin and normal.

### Notes:
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
