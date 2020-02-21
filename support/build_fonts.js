#! /usr/bin/env node

const path = require('path');
const { execSync } = require('child_process');
const fs = require('fs');

const convertor = '../node_modules/.bin/lv_font_conv';
const roboto = '../node_modules/roboto-fontface/fonts/roboto/Roboto-Medium.woff';
const outdir = '../src/gui/fonts';


let out_file;
let bpp = 3;
let compression = '';

if (process.argv[2] == 'nocompress') {
  bpp = 4;
  compression = '--no-compress';
}

const commons = `--bpp ${bpp} ${compression} --lcd --format lvgl --lv-include lvgl.h --force-fast-kern-format`;

out_file = path.join(outdir, 'my_font_roboto_14.c');
console.log(`Build ${path.join(__dirname, out_file)}`);
execSync(`${convertor} ${commons} --size 14 --font ${roboto} --range 0x20-0x7F -o ${out_file}`, { stdio: 'inherit', cwd: __dirname });

out_file = path.join(outdir, 'my_font_roboto_16.c');
console.log(`Build ${path.join(__dirname, out_file)}`);
execSync(`${convertor} ${commons} --size 16 --font ${roboto} --range 0x20-0x7F -o ${out_file}`, { stdio: 'inherit', cwd: __dirname });
