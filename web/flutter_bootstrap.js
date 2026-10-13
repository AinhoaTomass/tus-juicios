{{flutter_js}}
{{flutter_build_config}}

// Igual que el arranque por defecto de Flutter, pero quitando la pantalla
// de carga (#cargando en index.html) en cuanto la app se ha dibujado.
_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
    const cargando = document.getElementById('cargando');
    if (cargando) {
      cargando.style.opacity = '0';
      setTimeout(() => cargando.remove(), 300);
    }
  },
});
