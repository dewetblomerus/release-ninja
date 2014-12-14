(function() {
  var ListCtrl = function(projects, $scope) {
    this.projects = projects;
  };

  var NewCtrl = function($scope, Restangular, $state) {
    var self = this;
    $scope.data = {};

    Restangular.all("github/repositories").getList().then(function(repos) {
      self.repos = repos;
    });

    // Checkbox inputs product an object which has falsy values
    // This will remove those so only the true keys are left
    $scope.$watch('data.repos', function(repos) {
      _.each(repos, function(value, key) {
        if (!value) {
          delete repos[key];
        }
      });
    }, true);

    $scope.create = function(data) {
      var postData = cleanCloneData(data);
      $scope.processing = true;

      Restangular.all("projects").post(postData).then(function(project) {
        $state.go("projects.list");
      }).finally(function() {
        $scope.processing = false;
      });
    };

    $scope.isValid = function(data) {
      var data = cleanCloneData(data);
      return data.title && data.repos && data.repos.length > 0;
    };

    function cleanCloneData(data) {
      var clone = _.clone(data);
      clone.repos = _.keys(clone.repos);
      return clone;
    }
  };

  var ShowCtrl = function($scope, project, notes, NoteGrouper, $filter) {
    var self = this;
    this.project = project;
    this.notes = notes.plain();
    this.groupedNotes = NoteGrouper(this.notes);

    this.severityLevels = {
      major: "Major",
      minor: "Minor",
      fix: "Fix"
    };

    this.save = function(note) {
      self.project.one("notes", note.id).customPUT(note).then(function() {
        self.project.one("notes", note.id).get().then(function(note) {
          replaceNote(note);
        });
      });
    };

    this.new = function(note) {
      self.project.all("notes").post(note).then(function(createdNote) {
        $scope.newNote = false;
        self.notes.push(createdNote);
        resetGroupedNotes();
      });
    };

    this.remove = function(note) {
      self.project.one("notes", note.id).remove().then(function() {
        _.remove(self.notes, {id: note.id});
        resetGroupedNotes();
      });
    };

    this.anyPublished = function(notes) {
      return _(notes).any({published: true});
    };

    $scope.$watch('filterTitle', function() {
      resetGroupedNotes();
    });

    function replaceNote(note) {
      var index = _(self.notes).findIndex({id: note.id});
      self.notes[index] = note;
      self.groupedNotes = NoteGrouper(self.notes);
      resetGroupedNotes();
    }

    function resetGroupedNotes() {
      if($scope.filterTitle) {
        var title = $scope.filterTitle.toLowerCase();
        var notes = $filter('filter')(self.notes, function(note) {
          return note.title.toLowerCase().indexOf(title) > -1 || note.markdown_body.toLowerCase().indexOf(title) > -1;
        });
        self.groupedNotes = NoteGrouper(notes);
      } else {
        self.groupedNotes = NoteGrouper(self.notes);
      }
    }
  };

  ListCtrl.$inject = ["projects", "$scope"];
  NewCtrl.$inject = ["$scope", "Restangular", "$state"];
  ShowCtrl.$inject = ["$scope", "project", "notes", "NoteGrouper", "$filter"];

  angular.module("projects").controller('ProjectsListController', ListCtrl)
                            .controller('ProjectsNewController', NewCtrl)
                            .controller('ProjectsShowController', ShowCtrl);
})();
