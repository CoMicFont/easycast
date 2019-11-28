Q3D.gui = {

  type: "dat-gui",

  parameters: {
    lyr: [],
    cp: {
      c: "#ffffff",
      d: 0,
      o: 1,
      l: false
    },
    cmd: {         // commands for touch screen devices
      rot: false,  // auto rotation
      wf: false    // wireframe mode
    },
    i: Q3D.application.showInfo
  },

  // initialize gui
  // - setupDefaultItems: default is true
  init: function (setupDefaultItems) {
    this.gui = new dat.GUI();
    this.gui.domElement.parentElement.style.zIndex = 1000;   // display the panel on the front of labels
    if (setupDefaultItems === undefined || setupDefaultItems == true) {
      this.addLayersFolder();
      if (Q3D.isTouchDevice) this.addCommandsFolder();
    }
  },

  addLayersFolder: function () {
    var mapLayers = Q3D.application.scene.mapLayers;
    var parameters = this.parameters;
    var visibleChanged = function (value) { mapLayers[this.object.i].visible = value; };

    var layer, layersFolder = this.gui;
    for (var layerId in mapLayers) {
      layer = mapLayers[layerId];
      console.log(layerId, layer);
      parameters.lyr[layerId] = {i: layerId, v: layer.visible, o: layer.opacity};
      layersFolder.add(parameters.lyr[layerId], 'v').name(layer.properties.name).onChange(visibleChanged);
    }
  },

  initCustomPlaneFolder: function (zMin, zMax) {
    var app = Q3D.application,
        scene = app.scene,
        p = scene.userData;

    var customPlane;
    var parameters = this.parameters;
    var addPlane = function (color) {
      // Add a new plane in the current scene
      var geometry = new THREE.PlaneBufferGeometry(p.width,p.height, 1, 1),
          material = new THREE.MeshLambertMaterial({color: color, transparent: true});
      if (!Q3D.isIE) material.side = THREE.DoubleSide;
      customPlane = new THREE.Mesh(geometry, material);
      scene.add(customPlane);
      Q3D.gui.customPlane = customPlane;
      app.render();
    };
    parameters.cp.d = zMin;

  },

  // add commands folder for touch screen devices
  addCommandsFolder: function () {
    var folder = this.gui.addFolder('Commands');
    if (Q3D.Controls.type == "OrbitControls") {
      folder.add(this.parameters.cmd, 'rot').name('Rotate Animation').onChange(Q3D.application.setWireframeMode);
    }
    folder.add(this.parameters.cmd, 'wf').name('Wireframe Mode').onChange(Q3D.application.setWireframeMode);
  },

  addHelpButton: function () {
    this.gui.add(this.parameters, 'i').name('Help');
  }
};
