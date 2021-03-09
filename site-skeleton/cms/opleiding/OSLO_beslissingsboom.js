function highlightArea(area){
    let shapes = getShapes(area);
    for(let shape of shapes){
        shape.style.stroke = '#0066cc';
    }
}

function getShapes(area){
    let shapes = [];
    switch (area) {
        case 'session1':
        case 'session2':
        case 'session3':
        case 'session4':
        case 'session5':
        case 'session6':
        case 'session7':
        case 'oslo':
        case 'proces':
            shapes = Array.from(document.getElementById(area).getElementsByTagName('rect'));
            break;
    }
    return shapes;
}

function reset(){
    let rect = Array.from(document.getElementById('overlay').getElementsByTagName('rect'));
    let lines = Array.from(document.getElementById('overlay').getElementsByTagName('line'));
    let circles = Array.from(document.getElementById('overlay').getElementsByTagName('circle'));
    let polygon = Array.from(document.getElementById('overlay').getElementsByTagName('polygon'));

    let shapes = rect.concat(lines, circles, polygon);
    for(let shape of shapes){
        shape.style.stroke = null;
    }
}
