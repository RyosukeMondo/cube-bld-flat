// ====== 基本パラメータ ======
const GRID_W = 11, GRID_H = 13, U = 36; // 396×468 viewBox

// 色は仮（自由に変更可）
const COLORS = {
  leftBand:  '#c9743c',
  rightBand: '#ef1a1a',
  yellow:    '#efe23a',
  back:      '#8fb2e9',
  top:       '#ffffff',
  front:     '#b7f47a',
  textDark:  '#10141b',
  textLight: '#0e0e10'
};

// ====== 定義モデル ======
/** item: { key, x1, y1, x2, y2, fill, char }
 *  - (x1,y1) は左上、(x2,y2) は右下を含むグリッド座標（0-index, 右下=10,12）
 *  - 優先度は「外周ほど高い」。あと勝ち更新なので、中心→外周の順に適用。
 */

// まずは仕組みを実証するために最小セットを定義。
// 例: 小文字 j と r の帯、中央の Back/Top/Front、上下の Down。
// A–X/センター54件はこのフォーマットで追加入力してください（順序はアルファベット順でOK）。
const defs = [
  // --- Base bands ---
  { key:'j',  x1:0, y1:0, x2:3,  y2:12, fill: COLORS.leftBand,  char:'j', z:0 },
  { key:'r',  x1:7, y1:0, x2:10, y2:12, fill: COLORS.rightBand, char:'r', z:0 },
  
  // --- second large bands ---
  { key:'J', x1:1, y1:1, x2:3, y2:5, fill: COLORS.leftBand, char:'J', z:1 },
  { key:'k', x1:2, y1:3, x2:3, y2:5, fill: COLORS.leftBand, char:'k', z:2 },
  { key:'K', x1:3, y1:4, x2:3, y2:5, fill: COLORS.leftBand, char:'K', z:3 },

  { key:'I', x1:1, y1:7, x2:3, y2:10, fill: COLORS.leftBand, char:'I', z:1 },
  { key:'i', x1:2, y1:7, x2:3, y2:9,  fill: COLORS.leftBand, char:'i', z:2 },
  { key:'L', x1:3, y1:7, x2:3, y2:8, fill: COLORS.leftBand, char:'L', z:3 },

  { key:'Q', x1:7, y1:1, x2:9, y2:5, fill: COLORS.rightBand, char:'Q', z:1 },
  { key:'q', x1:7, y1:3, x2:8, y2:5, fill: COLORS.rightBand, char:'q', z:2 },
  { key:'T', x1:7, y1:4, x2:7, y2:5, fill: COLORS.rightBand, char:'T', z:3 },

  { key:'R', x1:7, y1:7, x2:9, y2:10, fill: COLORS.rightBand, char:'R', z:1 },
  { key:'r', x1:7, y1:7, x2:8, y2:9,  fill: COLORS.rightBand, char:'r', z:2 },
  { key:'S', x1:7, y1:7, x2:7, y2:8, fill: COLORS.rightBand, char:'S', z:3 },

  // --- center faces ---
  { key:'Down0', x1:5, y1:0, x2:5, y2:0, fill: COLORS.yellow, char:'Down', z:5 },
  { key:'Back', x1:5, y1:3, x2:5, y2:3, fill: COLORS.back, char:'Back', z:5 },
  { key:'Top', x1:5, y1:6, x2:5, y2:6, fill: COLORS.top, char:'Top', z:5 },
  { key:'Front', x1:5, y1:9, x2:5, y2:9, fill: COLORS.front, char:'Front', z:5 },
  { key:'Down1', x1:5, y1:12, x2:5, y2:12, fill: COLORS.yellow, char:'Down', z:5 },
  { key:'Left', x1:2, y1:6, x2:2, y2:6, fill: COLORS.leftBand, char:'Left', z:5 },
  { key:'Right', x1:8, y1:6, x2:8, y2:6, fill: COLORS.rightBand, char:'Right', z:5 },

  // --- other small cells --
  // Row 0: j j j j w Down u r r r r
  { key:'w', x1:4, y1:0, x2:4, y2:0, fill: COLORS.yellow, char:'w', z:4 },
  { key:'u', x1:6, y1:0, x2:6, y2:0, fill: COLORS.yellow, char:'u', z:4 },

  // Row 1: j J J J V v U Q Q Q r
  { key:'V', x1:4, y1:1, x2:4, y2:1, fill: COLORS.yellow, char:'V', z:4 },
  { key:'v', x1:5, y1:1, x2:5, y2:1, fill: COLORS.yellow, char:'v', z:4 },
  { key:'U', x1:6, y1:1, x2:6, y2:1, fill: COLORS.yellow, char:'U', z:4 },

  // Row 2: j J J J M n N Q Q Q r
  { key:'M', x1:4, y1:2, x2:4, y2:2, fill: COLORS.back, char:'M', z:4 },
  { key:'n', x1:5, y1:2, x2:5, y2:2, fill: COLORS.back, char:'n', z:4 },
  { key:'N', x1:6, y1:2, x2:6, y2:2, fill: COLORS.back, char:'N', z:4 },

  // Row 3: j J k k m Back o q q Q r
  { key:'m', x1:4, y1:3, x2:4, y2:3, fill: COLORS.back, char:'m', z:4 },
  { key:'o', x1:6, y1:3, x2:6, y2:3, fill: COLORS.back, char:'o', z:4 },

  // Row 4: j J k K P p O T q Q r
  { key:'P', x1:4, y1:4, x2:4, y2:4, fill: COLORS.back, char:'P', z:4 },
  { key:'p', x1:5, y1:4, x2:5, y2:4, fill: COLORS.back, char:'p', z:4 },
  { key:'O', x1:6, y1:4, x2:6, y2:4, fill: COLORS.back, char:'O', z:4 },

  // Row 5: j J k K C d D T q Q r
  { key:'C', x1:4, y1:5, x2:4, y2:5, fill: COLORS.top, char:'C', z:4 },
  { key:'d', x1:5, y1:5, x2:5, y2:5, fill: COLORS.top, char:'d', z:4 },
  { key:'D', x1:6, y1:5, x2:6, y2:5, fill: COLORS.top, char:'D', z:4 },

  // Row 6: j j Left l c Top a t Right r r
  { key:'l', x1:3, y1:6, x2:3, y2:6, fill: COLORS.leftBand, char:'l', z:4 },
  { key:'c', x1:4, y1:6, x2:4, y2:6, fill: COLORS.top, char:'c', z:4 },
  { key:'a', x1:6, y1:6, x2:6, y2:6, fill: COLORS.top, char:'a', z:4 },
  { key:'t', x1:7, y1:6, x2:7, y2:6, fill: COLORS.rightBand, char:'t', z:4 },

  // Row 7: j I i L B b A S s R r
  { key:'B', x1:4, y1:7, x2:4, y2:7, fill: COLORS.top, char:'B', z:4 },
  { key:'b', x1:5, y1:7, x2:5, y2:7, fill: COLORS.top, char:'b', z:4 },
  { key:'A', x1:6, y1:7, x2:6, y2:7, fill: COLORS.top, char:'A', z:4 },

  // Row 8: j I i L G h H S s R r
  { key:'G', x1:4, y1:8, x2:4, y2:8, fill: COLORS.front, char:'G', z:4 },
  { key:'h', x1:5, y1:8, x2:5, y2:8, fill: COLORS.front, char:'h', z:4 },
  { key:'H', x1:6, y1:8, x2:6, y2:8, fill: COLORS.front, char:'H', z:4 },

  // Row 9: j I i i g Front e s s R r
  { key:'g', x1:4, y1:9, x2:4, y2:9, fill: COLORS.front, char:'g', z:4 },
  { key:'e', x1:6, y1:9, x2:6, y2:9, fill: COLORS.front, char:'e', z:4 },

  // Row 10: j I I I F f E R R R r
  { key:'F', x1:4, y1:10, x2:4, y2:10, fill: COLORS.front, char:'F', z:4 },
  { key:'f', x1:5, y1:10, x2:5, y2:10, fill: COLORS.front, char:'f', z:4 },
  { key:'E', x1:6, y1:10, x2:6, y2:10, fill: COLORS.front, char:'E', z:4 },

  // Row 11: j I I I W x X R R R r
  { key:'W', x1:4, y1:11, x2:4, y2:11, fill: COLORS.yellow, char:'W', z:4 },
  { key:'x', x1:5, y1:11, x2:5, y2:11, fill: COLORS.yellow, char:'x', z:4 },
  { key:'X', x1:6, y1:11, x2:6, y2:11, fill: COLORS.yellow, char:'X', z:4 },

  // Row 12: j j j j w Down u r r r r
  { key:'w', x1:4, y1:12, x2:4, y2:12, fill: COLORS.yellow, char:'w', z:4 },
  { key:'u', x1:6, y1:12, x2:6, y2:12, fill: COLORS.yellow, char:'u', z:4 }
];


// ====== グリッド初期化＆あと勝ち適用 ======
function buildGrid(definitions){
  // 空グリッド
  const grid = Array.from({length:GRID_H}, () =>
    Array.from({length:GRID_W}, () => ({ fill:null, char:null, key:null }))
  );

  // 定義順にあと勝ちで適用（defs の並びが描画優先度）
  for(const d of definitions){
    for(let y=d.y1; y<=d.y2; y++){
      for(let x=d.x1; x<=d.x2; x++){
        grid[y][x] = { fill:d.fill, char:(d.char ?? ''), key:d.key };
      }
    }
  }
  return { grid, defs: definitions };
}

// ====== 描画 ======
const svg = document.getElementById('svg');
const tip = document.getElementById('tip');

function render(result){
  const { grid } = result;
  while(svg.firstChild) svg.removeChild(svg.firstChild);

  // セル矩形
  for(let y=0; y<GRID_H; y++){
    for(let x=0; x<GRID_W; x++){
      const cell = grid[y][x];
      const rect = document.createElementNS('http://www.w3.org/2000/svg','rect');
      rect.setAttribute('x', x*U+1);
      rect.setAttribute('y', y*U+1);
      rect.setAttribute('width', U-2);
      rect.setAttribute('height',U-2);
      rect.setAttribute('rx', 4);
      rect.setAttribute('fill', cell.fill || '#0f1421');
      rect.setAttribute('stroke', '#1b2539');
      rect.setAttribute('stroke-width', 1);
      rect.addEventListener('mousemove', (ev)=>{
        const bb = svg.getBoundingClientRect();
        tip.style.left = (ev.clientX - bb.left + 12) + 'px';
        tip.style.top  = (ev.clientY - bb.top + 12) + 'px';
        tip.style.opacity = 1;
        tip.textContent = `(${x},${y})  key:${cell.key ?? '-'}  char:${cell.char ?? ''}`;
      });
      rect.addEventListener('mouseleave', ()=> tip.style.opacity = 0);
      svg.appendChild(rect);

      if(cell.char){
        const t = document.createElementNS('http://www.w3.org/2000/svg','text');
        t.textContent = cell.char;
        t.setAttribute('class','cell-label');
        t.setAttribute('fill', '#0d1117');
        t.setAttribute('x', x*U + U/2);
        t.setAttribute('y', y*U + U/2);
        t.setAttribute('text-anchor','middle');
        t.setAttribute('dominant-baseline','middle');
        svg.appendChild(t);
      }
    }
  }

  // グリッド線（薄）
  //for(let x=1; x<GRID_W; x++){
  for(let x=GRID_W; x<GRID_W; x++){
    const v = document.createElementNS('http://www.w3.org/2000/svg','line');
    v.setAttribute('x1', x*U); v.setAttribute('y1', 0);
    v.setAttribute('x2', x*U); v.setAttribute('y2', GRID_H*U);
    v.setAttribute('stroke', '#121b2d'); v.setAttribute('stroke-width','1');
    svg.appendChild(v);
  }
  //for(let y=1; y<GRID_H; y++){
  for(let y=GRID_H; y<GRID_H; y++){
    const h = document.createElementNS('http://www.w3.org/2000/svg','line');
    h.setAttribute('x1', 0); h.setAttribute('y1', y*U);
    h.setAttribute('x2', GRID_W*U); h.setAttribute('y2', y*U);
    h.setAttribute('stroke', '#121b2d'); h.setAttribute('stroke-width','1');
    svg.appendChild(h);
  }
}

// 初期ビルド＋描画
const result = buildGrid(defs);
render(result);

// API を window に公開（定義の追加/再描画が簡単に）
window.RubikGrid = {
  GRID_W, GRID_H, U, COLORS,
  defs,
  add(def){ defs.push(def); const r = buildGrid(defs); render(r); return r; },
  rebuild(){ const r = buildGrid(defs); render(r); return r; },
};
