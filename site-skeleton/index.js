function highlightArea(area){
    let shapes = getShapes(area);
    for(let shape of shapes){
        shape.style.stroke = '#0066cc';
    }
}

function getShapes(area){
    let shapes = [];
    switch (area) {
        case 'website':
        case 'specs':
        case 'sparx':
            shapes = Array.from(document.getElementById(area).getElementsByTagName('rect'));
            break;
        case 'uml':
            shapes = Array.from(document.getElementById(area).getElementsByTagName('polygon'));
            break;
        case 'circleci':
            shapes = Array.from(document.getElementById('circleci').getElementsByTagName('circle'));
            break;
        case 'template-repo':
        case 'oslo-generated':
            let lines = Array.from(document.getElementById(area).getElementsByTagName('line'));
            let rect = Array.from(document.getElementById(area).getElementsByTagName('rect'));
            let circle = Array.from(document.getElementById(area).getElementsByTagName('circle'));
            shapes = lines.concat(rect, circle);
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
