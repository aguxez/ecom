import React, { Component } from "react";
import Dashboard from "./tabs/Dashboard";

export default class Admin extends Component {
  constructor(props) {
    super(props);

    this.state = {
      data: {}
    }
  }

  render() {
    return(
      <div>
        <ul className="tabs" data-tabs id="example-tabs">
          <li className="tabs-title is-active">
            <a href="#panel1" aria-selected="true"><strong>Interfaz</strong></a>
          </li>
        </ul>

        <div className="tabs-content" data-tabs-content="example-tabs">
          <div className="tabs-panel is-active" id="panel1">
            <Dashboard />
          </div>
        </div>
      </div>
    )
  }
}
