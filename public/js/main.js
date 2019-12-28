window.addEventListener("orientationchange", function () {
  if (screen.orientation.angle == 90 || screen.orientation.angle == 270) {
    alert('当サイトは横向きを想定していません。縦にお戻し下さい。');
  }
});

if (screen.orientation.angle == 90 || screen.orientation.angle == 270) {
  alert('当サイトは横向きを想定していません。縦にお戻し下さい。');
}


function previewFile() {
  var preview = document.getElementById('preview');
  var file = document.getElementById('up-img').files[0];
  var reader = new FileReader();

  reader.addEventListener("load", function () {
    preview.src = reader.result;
  }, false);

  loading_target = document.getElementById('loading-target')
  loading_target.setAttribute('class', 'loading-animation')
  icon_image = document.getElementById('user-icon-image')
  icon_image.setAttribute('class', 'user-icon-image-loading')

  var formData = new FormData();
  formData.append('up_image', file);

  var xhr = new XMLHttpRequest();
  xhr.open('POST', '/icon_image', true);
  xhr.send(formData);

  xhr.onreadystatechange = function () {
    if (xhr.readyState === 4) {
      if (xhr.status === 200) {
        console.log('sucsess. changed user-icon.');
        loading_target.removeAttribute('class');
        icon_image.removeAttribute('class');
      };
    };
  };

  if (file) {
    reader.readAsDataURL(file);
  };
};

function add_item() {
  var res = prompt('新規に追加するToDoのタイトルを入力して下さい。');
  if (res != null) {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '/new?title=' + res, true);
    xhr.send();
    xhr.onreadystatechange = function () {
      if (xhr.readyState === 4) {
        if (xhr.status === 200) {
          console.log('sucsess. add new task.');
          location.reload();
        };
      };
    };
  };
};

function form_input(ele) {
  var res = prompt(ele.value);
  if (res != null) {
    ele.value = res;
  };
};

function edit(id, now_title) {
  var res = prompt('「' + now_title + '」を変更します。新しいタイトルを入力して下さい。')
  if (res != null) {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '/edit?id=' + id + '&title=' + res, true);
    xhr.send();
    xhr.onreadystatechange = function () {
      if (xhr.readyState === 4) {
        if (xhr.status === 200) {
          console.log('sucsess. Edit Title.');
          location.reload();
        };
      };
    };
  };
}
