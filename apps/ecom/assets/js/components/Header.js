import React, { Component } from "react";
import { BrowserRouter, Link } from "react-router-dom";

export default class Header extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    let user = this.props.current_user;

    return(
      <BrowserRouter forceRefresh={true}>
        <div className="grid-container">
          <div className="grid-x grid-margin-x">
            <div className="text-center cell">
              <Link to="/">Home</Link>

              {
                // Login-logout section
                user ? (
                  <div>
                    <h3>Sesión iniciada como <strong>{user.username}</strong></h3>
                    <h4>
                      <Link
                        to={"/sessions/" + user.id}
                        data-method="delete"
                        data-csrf={this.props.csrf_token}
                      >
                        Cerrar sesión
                      </Link>
                    </h4>

                    <h4><Link to="/account">Cuenta</Link></h4>
                  </div>
                ) : (
                  <div>
                    <h4><Link to="/sessions/new">Iniciar sesión</Link></h4>
                    <h4><Link to="/register/new">Registrarse</Link></h4>
                  </div>
                )
                // End login-logout section
              }

              {
                // If 'user' exists and is admin
                user && user.overall &&
                <div>
                  <h4>
                    <Link to="/site_settings/">Admin panel</Link>
                  </h4>
                  <h4>
                    <Link to="/products/new">Añadir producto</Link>
                  </h4>
                </div>
              }
            </div>
          </div>
        </div>
      </BrowserRouter>
    )
  }
}
