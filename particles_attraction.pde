/**
 * <p>This example demonstrates how to use the behavior handling
 * (new since toxiclibs-0020 release) and specifically the attraction
 * behavior to create forces around the current locations of particles
 * in order to attract (or deflect) other particles nearby.</p>
 *
 * <p>Behaviors can be added and removed dynamically on both a
 * global level (for the entire physics simulation) as well as for
 * individual particles only.</p>
 * 
 * <p>Usage: Click and drag mouse to attract particles</p>
 */

/* 
 * Copyright (c) 2010 Karsten Schmidt
 * 
 * This demo & library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * http://creativecommons.org/licenses/LGPL/2.1/
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */
 
/**
 * I used this example to do some experiments
 * I added delaunay triangulation with the help of the mesh library :
 * http://www.leebyron.com/else/mesh/
 * Rayan Mestiri
 */
 
import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import megamu.mesh.*;

int NUM_PARTICLES = 700;

VerletPhysics2D physics;
AttractionBehavior mouseAttractor;
float [][] pos;
Vec2D mousePos;
Delaunay delaunay;
int [] polygons;

void setup() {
  size(1024, 768, P3D);
  // setup physics with 10% drag
  physics = new VerletPhysics2D();
  physics.setDrag(0.05f);
  physics.setWorldBounds(new Rect(0, 0, width, height));
  polygons = new int[NUM_PARTICLES];
  // the NEW way to add gravity to the simulation, using behaviors
  physics.addBehavior(new GravityBehavior(new Vec2D(0, 0.0f)));
    for (int i = 0; i<NUM_PARTICLES; i++) {
    addParticle();
  }
}

void addParticle() {
  VerletParticle2D p = new VerletParticle2D(Vec2D.randomVector().scale(500).addSelf(width / 2, 0));
  physics.addParticle(p);
  // add a negative attraction force field around the new particle
  physics.addBehavior(new AttractionBehavior(p, 40, -1.2f, 0.01f));
}

void draw() {
  background(0,0,0);
  noStroke();
  physics.update();
  drawParticles();
  drawLines();
}

void drawParticles() {
  // store particles positions to do delaunay triangulation
  pos = new float[NUM_PARTICLES][2];
  
  for ( int i=0; i<NUM_PARTICLES; i++) {
    // particle system using verlet integration
    VerletParticle2D p = physics.particles.get(i);
    fill(255, random(100,255));
    ellipse(p.x, p.y, 8, 8);
    pos[i][0] = physics.particles.get(i).x;
    pos[i][1] = physics.particles.get(i).y;
  }
}

// delaunay triangulation logic taken from here : 
// http://www.openprocessing.org/sketch/43503
void drawLines() {
  // delaunay triangulation
  delaunay = new Delaunay(pos);
  // getEdges returns a 2 dimensional array for the lines
  float[][] edges = delaunay.getEdges();
  for (int i=0; i<edges.length; i++)
  {
    // use the edges values to draw the lines
    float startX = edges[i][0];
    float startY = edges[i][1];
    float endX = edges[i][2];
    float endY = edges[i][3];
    float distance = dist(startX, startY, endX, endY);
    // remap the distance to opacity values
    float trans = 255-map(distance,0,60,0,255);
    // stroke weight based on distance
    // fast invert square root helps for performance
    float sw = 2.5f/sqrt(distance+1);
    strokeWeight(sw);
    stroke(255, trans);
    line(startX, startY, endX, endY);
  }
}

void mousePressed() {
  mousePos = new Vec2D(mouseX, mouseY);
  // create a new positive attraction force field around the mouse position (radius=250px)
  mouseAttractor = new AttractionBehavior(mousePos, 250, 1f);
  physics.addBehavior(mouseAttractor);
}

void mouseDragged() {
  // update mouse attraction focal point
  mousePos.set(mouseX, mouseY);
}

void mouseReleased() {
  // remove the mouse attraction when button has been released
  physics.removeBehavior(mouseAttractor);
}

