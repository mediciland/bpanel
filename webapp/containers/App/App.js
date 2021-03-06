import React, { PureComponent } from 'react';
import PropTypes from 'prop-types';
import { bindActionCreators } from 'redux';
import { Route, Redirect } from 'react-router';
import { getClient } from '@bpanel/bpanel-utils';

import ThemeProvider from '../ThemeProvider';
import {
  clientActions,
  nodeActions,
  socketActions,
  themeActions,
  navActions,
  appActions
} from '../../store/actions/';
import { APP_LOADED } from '../../store/constants/app';
import Header from '../Header';
import Footer from '../Footer';
import Sidebar from '../Sidebar';
import Panel from '../Panel';
import { nav } from '../../store/selectors';
import { pluginMetadata } from '../../store/propTypes';
import { connect } from '../../plugins/plugins';

import 'bootstrap/dist/css/bootstrap.min.css';
import 'bootstrap/dist/css/bootstrap-grid.min.css';

class App extends PureComponent {
  constructor(props) {
    super(props);
    props.loadSideNav();
    this.client = null;
    props.hydrateClients();
    this.updateClient = this.updateClient.bind(this);
  }

  static get propTypes() {
    return {
      children: PropTypes.node,
      loadSideNav: PropTypes.func.isRequired,
      sidebarNavItems: pluginMetadata.sortedMetadataPropTypes,
      location: PropTypes.shape({
        pathname: PropTypes.string
      }),
      theme: PropTypes.object,
      connectSocket: PropTypes.func.isRequired,
      disconnectSocket: PropTypes.func.isRequired,
      getNodeInfo: PropTypes.func.isRequired,
      getWindowInfo: PropTypes.func,
      updateTheme: PropTypes.func.isRequired,
      appLoaded: PropTypes.func.isRequired,
      hydrateClients: PropTypes.func.isRequired,
      resetClient: PropTypes.func.isRequired,
      match: PropTypes.shape({
        isExact: PropTypes.bool,
        path: PropTypes.string,
        url: PropTypes.string,
        params: PropTypes.object
      }).isRequired,
      clientsHydrated: PropTypes.bool,
      loading: PropTypes.bool
    };
  }

  async componentDidMount() {
    const { getNodeInfo, connectSocket } = this.props;
    this.client = getClient();
    this.client.on('set clients', this.updateClient);

    if (this.client.id) {
      connectSocket();
      getNodeInfo();
    }
  }

  updateClient(clientInfo) {
    const {
      resetClient,
      getNodeInfo,
      clientsHydrated,
      loading,
      connectSocket
    } = this.props;
    // only reset if clients have been hydrated
    // and the node is no longer loading
    if (clientsHydrated && !loading) resetClient(clientInfo);
    connectSocket();
    getNodeInfo();
  }

  UNSAFE_componentWillMount() {
    const { updateTheme, appLoaded, getWindowInfo } = this.props;

    getWindowInfo();
    updateTheme();
    appLoaded();
  }

  componentWillUnmount() {
    // Unload theming for the <body> and <html> tags
    document.body.className = null;
    document.document.documentElement.className = null;
    this.props.disconnectSocket();
    this.client.removeListener('set clients', this.updateClient);
  }

  getHomePath() {
    const { sidebarNavItems } = this.props;
    const panels = sidebarNavItems.filter(
      plugin => plugin.sidebar || plugin.nav || React.isValidElement(plugin)
    );
    const homePath = panels[0]
      ? panels[0].pathName ? panels[0].pathName : panels[0].name
      : '';
    return homePath;
  }

  render() {
    const { sidebarNavItems, location, theme, match } = this.props;
    return (
      <ThemeProvider theme={theme}>
        <React.Fragment>
          <div className={`${theme.app.container} container-fluid`} role="main">
            <div className="row">
              <div
                className={`${theme.app.sidebarContainer} col-sm-4 col-lg-3`}
              >
                <Sidebar
                  sidebarNavItems={sidebarNavItems}
                  location={location}
                  theme={theme}
                  match={match}
                />
              </div>
              <div className={`${theme.app.content} col-sm-8 col-lg-9`}>
                <Header />
                <Route
                  exact
                  path="/"
                  render={() => <Redirect to={`/${this.getHomePath()}`} />}
                />
                <Panel />
              </div>
            </div>
          </div>
          <Footer />
        </React.Fragment>
      </ThemeProvider>
    );
  }
}

const mapStateToProps = state => ({
  // by default the sidebar items stay in an unsorted state in the
  // redux store. Using the selector you can get them sorted (and
  // it will only recalculate if there's been a change in the state)
  sidebarNavItems: nav.sortedSidebarItems(state),
  theme: state.theme,
  clientsHydrated: state.clients.clientsHydrated,
  loading: state.node.loading
});

const mapDispatchToProps = dispatch => {
  const { getNodeInfo } = nodeActions;
  const { loadSideNav } = navActions;
  const { connectSocket, disconnectSocket } = socketActions;
  const { updateTheme } = themeActions;
  const { hydrateClients, resetClient } = clientActions;
  const { getWindowInfo } = appActions;
  const appLoaded = () => ({ type: APP_LOADED });
  return bindActionCreators(
    {
      appLoaded,
      hydrateClients,
      resetClient,
      getNodeInfo,
      loadSideNav,
      connectSocket,
      disconnectSocket,
      updateTheme,
      getWindowInfo
    },
    dispatch
  );
};

export default connect(mapStateToProps, mapDispatchToProps)(App, 'App');
