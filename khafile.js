let project = new Project('Kha_castledb');
project.addAssets('Assets/**');
project.addSources('Sources');
project.addLibrary("castle");
resolve(project);
