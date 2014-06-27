// <ul>
//   <li><a href="" scroll-to="section1">Section 1</a></li>
//   <li><a href="" scroll-to="section2">Section 2</a></li>
// </ul>

// <h1 id="section1">Hi, I'm section 1</h1>
// <p>
// Zombie ipsum reversus ab viral inferno, nam rick grimes malum cerebro. De carne lumbering animata corpora quaeritis. 
//  Summus brains sit​​, morbo vel maleficia? De apocalypsi gorger omero undead survivor dictum mauris. 
// Hi mindless mortuis soulless creaturas, imo evil stalking monstra adventus resi dentevil vultus comedat cerebella viventium. 
// Nescio brains an Undead zombies. Sicut malus putrid voodoo horror. Nigh tofth eliv ingdead.
// </p>

// <h1 id="section2">I'm totally section 2</h1>
// <p>
// Zombie ipsum reversus ab viral inferno, nam rick grimes malum cerebro. De carne lumbering animata corpora quaeritis. 
//  Summus brains sit​​, morbo vel maleficia? De apocalypsi gorger omero undead survivor dictum mauris. 
// Hi mindless mortuis soulless creaturas, imo evil stalking monstra adventus resi dentevil vultus comedat cerebella viventium. 
// Nescio brains an Undead zombies. Sicut malus putrid voodoo horror. Nigh tofth eliv ingdead.
// </p>
//

angular.module("scrollTo",[])
  .directive('scrollTo', function ($location, $anchorScroll) {
    return function(scope, element, attrs) {
      element.bind('click', function(event) {
        event.stopPropagation();
        scope.$on('$locationChangeStart', function(ev) {
            ev.preventDefault();
        });
        var location = attrs.scrollTo;
        $location.hash(location);
        $anchorScroll();
      });
    }
  });