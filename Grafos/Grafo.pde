import java.util.ArrayList;
import java.util.Collections;

class Grafo {
  int numVertices;
  int[][] matrizAdj;
  PVector[] posicoes; 
  PVector[] velocidades; 
  float raio = 10; 
  float k = 0.001; 
  float c = 3000; 
  ArrayList<Integer> caminhoMinimo; 
  
  Grafo(int numVertices) {
    this.numVertices = numVertices;
    matrizAdj = new int[numVertices][numVertices];
    posicoes = new PVector[numVertices];
    velocidades = new PVector[numVertices];
    inicializarPosicoes();
    caminhoMinimo = new ArrayList<>();
  }
  
  Grafo(int[][] adj) {
    this.numVertices = adj.length;
    matrizAdj = adj;
    posicoes = new PVector[numVertices];
    velocidades = new PVector[numVertices];
    inicializarPosicoes();
    caminhoMinimo = new ArrayList<>();
  }

  void adicionarAresta(int i, int j) {
    matrizAdj[i][j] = 1;
    matrizAdj[j][i] = 1;
  }
  
  void adicionarAresta(int i, int j, int peso) {
    matrizAdj[i][j] = peso;
    matrizAdj[j][i] = peso;
  }

  void inicializarPosicoes() {
    float angulo = TWO_PI / (numVertices - 1);
    float raioCirculo = min(width, height) / 3;
    for (int i = 1; i < numVertices; i++) {
      float x = width / 2 + raioCirculo * cos((i - 1) * angulo);
      float y = height / 2 + raioCirculo * sin((i - 1) * angulo);
      posicoes[i] = new PVector(x, y);
      velocidades[i] = new PVector(0, 0);
    }
    posicoes[0] = new PVector(width / 2, height / 2);
    velocidades[0] = new PVector(0, 0);
  }

  void atualizar() {
    for (int i = 1; i < numVertices; i++) {
      PVector forca = new PVector(0, 0);
      
      for (int j = 0; j < numVertices; j++) {
        if (i != j) {
          PVector direcao = PVector.sub(posicoes[i], posicoes[j]);
          float distancia = direcao.mag();
          if (distancia > 0) {
            direcao.normalize();
            float forcaRepulsao = c / (distancia * distancia);
            direcao.mult(forcaRepulsao);
            forca.add(direcao);
          }
        }
      }

      for (int j = 0; j < numVertices; j++) {
        if (matrizAdj[i][j] > 0) {
          PVector direcao = PVector.sub(posicoes[j], posicoes[i]);
          float distancia = direcao.mag();
          direcao.normalize();
          float forcaAtracao = k * (distancia - raio);
          direcao.mult(forcaAtracao);
          forca.add(direcao);
        }
      }

      velocidades[i].add(forca);
      posicoes[i].add(velocidades[i]);
      velocidades[i].mult(0.5);

      if (posicoes[i].x < 0 || posicoes[i].x > width) velocidades[i].x *= -1; 
      if (posicoes[i].y < 0 || posicoes[i].y > height) velocidades[i].y *= -1;
    }
  }

  void desenhar() {
    textAlign(CENTER);
    stroke(0);
    strokeWeight(1);
    for (int i = 0; i < numVertices; i++) {
      for (int j = i + 1; j < numVertices; j++) {
        strokeWeight(matrizAdj[i][j]);
        if (matrizAdj[i][j] > 0) {
          if (caminhoMinimo.contains(i) && caminhoMinimo.contains(j) && 
              Math.abs(caminhoMinimo.indexOf(i) - caminhoMinimo.indexOf(j)) == 1) {
            stroke(255, 0, 0);
          } else {
            stroke(0);
          }
          line(posicoes[i].x, posicoes[i].y, posicoes[j].x, posicoes[j].y);
        }
      }
    }

    fill(255);
    stroke(0);
    strokeWeight(1);
    for (int i = 0; i < numVertices; i++) {
      fill(255);
      ellipse(posicoes[i].x, posicoes[i].y, raio * 2, raio * 2);
      fill(0);
      text(str(i), posicoes[i].x, posicoes[i].y + 4);
    }
  }

  ArrayList<Integer> dijkstra(int origem, int destino) {
    int[] dist = new int[numVertices];
    int[] anterior = new int[numVertices];
    boolean[] visitado = new boolean[numVertices];
    for (int i = 0; i < numVertices; i++) {
      dist[i] = Integer.MAX_VALUE;
      anterior[i] = -1;
      visitado[i] = false;
    }
    
    dist[origem] = 0;

    for (int i = 0; i < numVertices - 1; i++) {
      int u = -1;
      for (int j = 0; j < numVertices; j++) {
        if (!visitado[j] && (u == -1 || dist[j] < dist[u])) {
          u = j;
        }
      }
      
      if (dist[u] == Integer.MAX_VALUE) break;
      
      visitado[u] = true;
      
      for (int v = 0; v < numVertices; v++) {
        if (matrizAdj[u][v] != 0 && !visitado[v]) {
          int alt = dist[u] + matrizAdj[u][v];
          if (alt < dist[v]) {
            dist[v] = alt;
            anterior[v] = u;
          }
        }
      }
    }

    caminhoMinimo.clear();
    ArrayList<Integer> caminho = new ArrayList<>();
    for (int u = destino; u != -1; u = anterior[u]) {
      caminho.add(u);
    }
    Collections.reverse(caminho);
    caminhoMinimo.addAll(caminho);
    return caminho;
  }
}
