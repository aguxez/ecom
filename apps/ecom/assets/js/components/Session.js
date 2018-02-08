import React, { Component } from 'react';

export default class Session extends Component {
  constructor(props) {
    super(props);
  }

  componentDidMount() {
    console.log(this.props);
  }

  render() {
    let user = this.props.current_user;

    return(
      <div className="grid-container">
        <div className="grid-x grid-margin-x">
          <div className="text-center cell">
            {
              user ? (
                <div>
                  <h3>Sesión iniciada como <strong>{user.username}</strong></h3>
                  <h4>
                    <a
                      data-csrf={this.props.csrf_token}
                      data-to={'/sessions/' + user.id}
                      data-method="delete"
                      href="#"
                      rel="nofollow"
                    >
                      Cerrar sesión
                    </a>
                  </h4>
                </div>
              ) : (
                <div>
                  <h4><a href="/sessions/new">Iniciar sesión</a></h4>
                  <h4><a href="/register/new">Registrarse</a></h4>
                </div>
              )
            }
          </div>
        </div>
      </div>
    )
  }
}
