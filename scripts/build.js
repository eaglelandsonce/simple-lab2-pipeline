#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Create dist directory if it doesn't exist
const distDir = path.join(__dirname, '../dist');
if (!fs.existsSync(distDir)) {
  fs.mkdirSync(distDir, { recursive: true });
}

// Copy source files to dist
const srcDir = path.join(__dirname, '../src');
const files = fs.readdirSync(srcDir);
files.forEach(file => {
  if (file.endsWith('.js')) {
    fs.copyFileSync(
      path.join(srcDir, file),
      path.join(distDir, file)
    );
  }
});

// Generate build-info.json
const buildInfo = {
  buildTime: new Date().toISOString(),
  buildNumber: process.env.GITHUB_RUN_NUMBER || 'local',
  gitCommit: process.env.GITHUB_SHA || 'unknown',
  gitBranch: process.env.GITHUB_REF_NAME || 'local',
  environment: process.env.NODE_ENV || 'development',
  nodeVersion: process.version
};

fs.writeFileSync(
  path.join(distDir, 'build-info.json'),
  JSON.stringify(buildInfo, null, 2)
);

console.log('✅ Build completed successfully!');
console.log('📦 Build info:', buildInfo);
