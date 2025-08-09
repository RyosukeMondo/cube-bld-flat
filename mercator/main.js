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

  { key:'I', x1:1, y1:7, x2:3, y2:11, fill: COLORS.leftBand, char:'I', z:1 },
  { key:'i', x1:2, y1:7, x2:3, y2:9,  fill: COLORS.leftBand, char:'i', z:2 },
  { key:'L', x1:3, y1:7, x2:3, y2:8, fill: COLORS.leftBand, char:'L', z:3 },

  { key:'Q', x1:7, y1:1, x2:9, y2:5, fill: COLORS.rightBand, char:'Q', z:1 },
  { key:'q', x1:7, y1:3, x2:8, y2:5, fill: COLORS.rightBand, char:'q', z:2 },
  { key:'T', x1:7, y1:4, x2:7, y2:5, fill: COLORS.rightBand, char:'T', z:3 },

  { key:'R', x1:7, y1:7, x2:9, y2:11, fill: COLORS.rightBand, char:'R', z:1 },
  { key:'r', x1:7, y1:7, x2:8, y2:9,  fill: COLORS.rightBand, char:'r', z:2 },
  { key:'S', x1:7, y1:7, x2:7, y2:8, fill: COLORS.rightBand, char:'S', z:3 },

  // --- center faces ---
  { key:'Down0', x1:5, y1:0, x2:5, y2:0, fill: COLORS.yellow, char:'Down', z:0 },
  { key:'Back', x1:5, y1:3, x2:5, y2:3, fill: COLORS.back, char:'Back', z:2 },
  { key:'Top', x1:5, y1:6, x2:5, y2:6, fill: COLORS.top, char:'Top', z:3 },
  { key:'Front', x1:5, y1:9, x2:5, y2:9, fill: COLORS.front, char:'Front', z:2 },
  { key:'Down1', x1:5, y1:12, x2:5, y2:12, fill: COLORS.yellow, char:'Down', z:0 },
  { key:'Left', x1:2, y1:6, x2:2, y2:6, fill: COLORS.leftBand, char:'Left', z:2 },
  { key:'Right', x1:8, y1:6, x2:8, y2:6, fill: COLORS.rightBand, char:'Right', z:2 },

  // --- other small cells --
  // Row 0: j j j j w Down u r r r r
  { key:'w', x1:4, y1:0, x2:4, y2:0, fill: COLORS.yellow, char:'w', z:0 },
  { key:'u', x1:6, y1:0, x2:6, y2:0, fill: COLORS.yellow, char:'u', z:0 },

  // Row 1: j J J J V v U Q Q Q r
  { key:'V', x1:4, y1:1, x2:4, y2:1, fill: COLORS.yellow, char:'V', z:1 },
  { key:'v', x1:5, y1:1, x2:5, y2:1, fill: COLORS.yellow, char:'v', z:1 },
  { key:'U', x1:6, y1:1, x2:6, y2:1, fill: COLORS.yellow, char:'U', z:1 },

  // Row 2: j J J J M n N Q Q Q r
  { key:'M', x1:4, y1:2, x2:4, y2:2, fill: COLORS.back, char:'M', z:1 },
  { key:'n', x1:5, y1:2, x2:5, y2:2, fill: COLORS.back, char:'n', z:1 },
  { key:'N', x1:6, y1:2, x2:6, y2:2, fill: COLORS.back, char:'N', z:1 },

  // Row 3: j J k k m Back o q q Q r
  { key:'m', x1:4, y1:3, x2:4, y2:3, fill: COLORS.back, char:'m', z:2 },
  { key:'o', x1:6, y1:3, x2:6, y2:3, fill: COLORS.back, char:'o', z:2 },

  // Row 4: j J k K P p O T q Q r
  { key:'P', x1:4, y1:4, x2:4, y2:4, fill: COLORS.back, char:'P', z:3 },
  { key:'p', x1:5, y1:4, x2:5, y2:4, fill: COLORS.back, char:'p', z:3 },
  { key:'O', x1:6, y1:4, x2:6, y2:4, fill: COLORS.back, char:'O', z:3 },

  // Row 5: j J k K C d D T q Q r
  { key:'C', x1:4, y1:5, x2:4, y2:5, fill: COLORS.top, char:'C', z:3 },
  { key:'d', x1:5, y1:5, x2:5, y2:5, fill: COLORS.top, char:'d', z:3 },
  { key:'D', x1:6, y1:5, x2:6, y2:5, fill: COLORS.top, char:'D', z:3 },

  // Row 6: j j Left l c Top a t Right r r
  { key:'l', x1:3, y1:6, x2:3, y2:6, fill: COLORS.leftBand, char:'l', z:3 },
  { key:'c', x1:4, y1:6, x2:4, y2:6, fill: COLORS.top, char:'c', z:3 },
  { key:'a', x1:6, y1:6, x2:6, y2:6, fill: COLORS.top, char:'a', z:3 },
  { key:'t', x1:7, y1:6, x2:7, y2:6, fill: COLORS.rightBand, char:'t', z:3 },

  // Row 7: j I i L B b A S s R r
  { key:'B', x1:4, y1:7, x2:4, y2:7, fill: COLORS.top, char:'B', z:3 },
  { key:'b', x1:5, y1:7, x2:5, y2:7, fill: COLORS.top, char:'b', z:3 },
  { key:'A', x1:6, y1:7, x2:6, y2:7, fill: COLORS.top, char:'A', z:3 },

  // Row 8: j I i L G h H S s R r
  { key:'G', x1:4, y1:8, x2:4, y2:8, fill: COLORS.front, char:'G', z:3 },
  { key:'h', x1:5, y1:8, x2:5, y2:8, fill: COLORS.front, char:'h', z:3 },
  { key:'H', x1:6, y1:8, x2:6, y2:8, fill: COLORS.front, char:'H', z:3 },

  // Row 9: j I i i g Front e s s R r
  { key:'g', x1:4, y1:9, x2:4, y2:9, fill: COLORS.front, char:'g', z:2 },
  { key:'e', x1:6, y1:9, x2:6, y2:9, fill: COLORS.front, char:'e', z:2 },

  // Row 10: j I I I F f E R R R r
  { key:'F', x1:4, y1:10, x2:4, y2:10, fill: COLORS.front, char:'F', z:1 },
  { key:'f', x1:5, y1:10, x2:5, y2:10, fill: COLORS.front, char:'f', z:1 },
  { key:'E', x1:6, y1:10, x2:6, y2:10, fill: COLORS.front, char:'E', z:1 },

  // Row 11: j I I I W x X R R R r
  { key:'W', x1:4, y1:11, x2:4, y2:11, fill: COLORS.yellow, char:'W', z:1 },
  { key:'x', x1:5, y1:11, x2:5, y2:11, fill: COLORS.yellow, char:'x', z:1 },
  { key:'X', x1:6, y1:11, x2:6, y2:11, fill: COLORS.yellow, char:'X', z:1 },

  // Row 12: j j j j w Down u r r r r
  { key:'w', x1:4, y1:12, x2:4, y2:12, fill: COLORS.yellow, char:'w', z:0 },
  { key:'u', x1:6, y1:12, x2:6, y2:12, fill: COLORS.yellow, char:'u', z:0 }
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

// ====== 描画（CSS 3D） ======
const world = document.getElementById('world');
const tip = document.getElementById('tip');
// world サイズをグリッドに合わせる
world.style.width = (GRID_W * U) + 'px';
world.style.height = (GRID_H * U) + 'px';

// 3D 回転（ドラッグで操作）
let rotX = 18, rotY = -22; // 初期角度（CSS 初期値と合わせる）
let zoomZ = 0;             // カメラ方向へのズーム距離（px）
let isDragging = false, lastX = 0, lastY = 0;
const scene = document.querySelector('.scene');
const camera = document.querySelector('.camera');

function applyTransform(){
  world.style.transform = `translate3d(-50%,-50%,${zoomZ}px) rotateX(${rotX}deg) rotateY(${rotY}deg)`;
}
applyTransform();

function onPointerDown(e){
  isDragging = true;
  lastX = e.clientX ?? (e.touches && e.touches[0].clientX) ?? 0;
  lastY = e.clientY ?? (e.touches && e.touches[0].clientY) ?? 0;
  scene.classList.add('dragging');
}
function onPointerMove(e){
  if(!isDragging) return;
  const x = e.clientX ?? (e.touches && e.touches[0].clientX) ?? 0;
  const y = e.clientY ?? (e.touches && e.touches[0].clientY) ?? 0;
  const dx = x - lastX;
  const dy = y - lastY;
  rotY += dx * 0.3; // 横ドラッグで Y 回転
  rotX -= dy * 0.3; // 縦ドラッグで X 回転
  rotX = Math.max(-89, Math.min(89, rotX)); // 上下に回りすぎ防止
  lastX = x; lastY = y;
  applyTransform();
}
function onPointerUp(){ isDragging = false; scene.classList.remove('dragging'); }

scene.addEventListener('mousedown', onPointerDown);
scene.addEventListener('mousemove', onPointerMove);
window.addEventListener('mouseup', onPointerUp);
scene.addEventListener('touchstart', onPointerDown, {passive:true});
scene.addEventListener('touchmove', onPointerMove, {passive:true});
window.addEventListener('touchend', onPointerUp);

// マウスホイールでズーム
function onWheel(e){
  e.preventDefault();
  const sensitivity = 0.6; // 値を大きくするとズーム速度が上がる
  // 通常: 下回し(deltaY>0)で遠ざかる、上回しで近づく
  zoomZ -= e.deltaY * sensitivity;
  // 過度なズームを防止
  zoomZ = Math.max(-900, Math.min(900, zoomZ));
  applyTransform();
}
scene.addEventListener('wheel', onWheel, { passive:false });

function render(result){
  const { defs } = result;
  while(world.firstChild) world.removeChild(world.firstChild);

  // CSS 3D: 各定義を 1 つのセルボックスとして配置
  for(const d of defs){
    const x = d.x1;
    const y = d.y1;
    const wCells = (d.x2 - d.x1 + 1);
    const hCells = (d.y2 - d.y1 + 1);
    const zUnit = parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--z')) || 12;
    const z = (d.z ?? 0) * zUnit;

    const el = document.createElement('div');
    el.className = 'cell draggable';
    el.style.left = (x*U + 1) + 'px';
    el.style.top = (y*U + 1) + 'px';
    el.style.width = (wCells*U - 2) + 'px';
    el.style.height = (hCells*U - 2) + 'px';
    el.style.background = d.fill || '#0f1421';
    el.style.transform = `translateZ(${z}px)`;
    el.style.outline = 'none';

    // ツールチップ
    el.addEventListener('mousemove', (ev)=>{
      const bb = world.getBoundingClientRect();
      tip.style.left = (ev.clientX - bb.left + 12) + 'px';
      tip.style.top  = (ev.clientY - bb.top + 12) + 'px';
      tip.style.opacity = 1;
      tip.textContent = `(${d.x1},${d.y1})-(${d.x2},${d.y2}) z:${d.z ?? 0} key:${d.key ?? '-'} char:${d.char ?? ''}`;
    });
    el.addEventListener('mouseleave', ()=> tip.style.opacity = 0);

    // ラベル
    if(d.char){
      const label = document.createElement('div');
      label.className = 'label';
      label.textContent = d.char;
      // アラインメント類似ロジック
      if(d.fill === COLORS.leftBand){
        label.style.left = '8px';
        label.style.transform = 'translate(0,-50%)';
        label.style.textAlign = 'left';
      }else if(d.fill === COLORS.rightBand){
        label.style.left = '';
        label.style.right = '8px';
        label.style.transform = 'translate(0,-50%)';
        label.style.textAlign = 'right';
      }
      el.appendChild(label);
    }

    world.appendChild(el);
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
