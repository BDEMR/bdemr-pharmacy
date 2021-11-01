Polymer({
  is: 'page-news-feed',
  behaviors: [
    app.behaviors.dbUsing,
    app.behaviors.pageLike,
    app.behaviors.translating,
    app.behaviors.apiCalling,
    app.behaviors.commonComputes,
  ],
  properties: {
    filterBy:{
      type: Object,
      value: {
        fromDate: null,
        toDate: null,
      }
    },

    childOrganizationList: {
      type: Array,
      notify: true,
      value: []
    },

    user: {
      type: Object,
      value: (app.db.find ('user'))[0]
    },
    organization: {
      type: Object,
      value: ()=> (app.db.find ('organization'))[0]
    },

    EDIT_MODE: {
      type: Boolean,
      value: true,
    },

    post: Object,
    posts: {
      type: Array,
      value: []
    },
    availableMembers: Array,
    availableSharedList: Array,
    availableRoles: {
      type: Array,
      value: []
    },
    hideEditForm:{ type: Boolean, value: true },

    dayRange: {
      type: Array,
      value: ['Last Week', 'Last Month', 'Today', 'Yesterday', 'Choose Dates']
    },

    selectedDateRangeIndex:{
      type: Number,
      value: 0,
      observer: '_selectedDateRangeIndexChanged'
    },

  },


  _selectedDateRangeIndexChanged(selectedPageIndex) {

    if (selectedPageIndex == 0) {
      thisWeekStart = new Date(new Date().setDate(new Date().getDate()-7));
      thisWeekEnd = new Date();

      thisWeekStart = thisWeekStart.setHours(0, 0, 0, 0)
      thisWeekEnd = thisWeekEnd.setHours(23, 59, 59, 999)

      this.set('filterBy.fromDate', thisWeekStart);
      this.set('filterBy.toDate', thisWeekEnd);
    }
      
    if (selectedPageIndex == 1) {
      last30Days = new Date(new Date().setDate(new Date().getDate()-30));
      today = new Date();

      last30Days = last30Days.setHours(0, 0, 0, 0);
      today = today.setHours(23, 59, 59, 999);

      this.set('filterBy.fromDate', last30Days);
      this.set('filterBy.toDate', today);
    }
    
    // Today
    if (selectedPageIndex == 2) {
      today = new Date();
      todayStart = today.setHours(0, 0, 0, 0);
      todayEnd = today.setHours(23, 59, 59, 999);

      this.set('filterBy.fromDate', todayStart);
      this.set('filterBy.toDate', todayEnd);
    }
      
    
    // yesterday
    if (selectedPageIndex == 3) {
      yesterday = new Date(new Date().setDate(new Date().getDate()-1));

      yesterdayStart = yesterday.setHours(0, 0, 0, 0);
      yesterdayEnd = yesterday.setHours(23, 59, 59, 999);

      this.set('filterBy.fromDate', yesterdayStart);
      this.set('filterBy.toDate', yesterdayEnd);
    }
      
    if (selectedPageIndex == 4) return;

    console.log(this.organization, this.user);

    if (this.organization && this.user) {
      this._callGetUserNewsFeed();
    }

  },
    
  attached() {
    
  },

  suspend() {
    
  },

  _editorHasOpened(hasOpened) {
    if (hasOpened) return '';
    return 'open';
  },

  _resetPost() {
    this.set('post', {
      createdDatetimeStamp: lib.datetime.now(),
      lastModifiedDatetimeStamp: lib.datetime.now(),

      createdByUserId: this.user.idOnServer,
      lastModifiedByUserId: this.user.idOnServer,

      organizationId: this.organization.idOnServer,
      authorName: this.user.name,
      
      message: '',
      attachments: [],
      shareWith: [],
      hasRequiredConfirmation: false,
      comments: [],
      newComment: '',
      isLoading: false,
    });
  },

  _insertAllRoleMembersToPost (selectedRole) {
    let list = [];
    list = list.concat(this.availableMembers);

    console.log(list, selectedRole);

    list.forEach((item) => {
      if (selectedRole == item.role) {
        // check if user exist already
        const userFound = this.post.shareWith.some((member) => member.userId == item.id);
        if (userFound) return;
        this.push('post.shareWith', {
          userId: item.id,
          type: item.type,
          name: item.name,
          hasConfirmed: false,
          role: item.role,
          roleSerial: item.roleSerial
        });
      }
    });
  },

  _addUserOnPost(e){
    e.preventDefault();
    this.set('shareWithValue', '');

    console.log(e);
    // index = e.model.index;
    item = e.detail.value;
    if (!item) return;


    if (item.type == 'role') {
      this._insertAllRoleMembersToPost(item.name);
    } else {

      // check if user exist already
      const userFound = this.post.shareWith.some((member) => member.userId == item.id);
      console.log({userFound});
      if (userFound) return;

      this.push('post.shareWith', {
        userId: item.id,
        type: item.type,
        name: item.name,
        hasConfirmed: false,
        role: item.role,
        roleSerial: item.roleSerial
      });
    }
    
  },

  _removeMember(e) {
    console.log(e);
    index = e.model.index;
    this.splice("post.shareWith", index, 1);
  },

  _addCommentOnPost(e){
    index = e.model.index;
    console.log(index);
    post = this.posts[index];
    newComment = post.newComment;

    if (!newComment) return;
    if (newComment.length < 2) return;
    
    post.comments.push({
      id: this.user.idOnServer,
      name: this.user.name,
      profileImage: null,
      message: newComment,
      createdDatetimeStamp: lib.datetime.now(),
      lastModifiedDatetimeStamp: lib.datetime.now(),
    });

    post.newComment = '';
    // path = "posts." + index;
 
    this._callSetNewsFeedPost( post, (newPost)=> {
      this._callGetUserNewsFeed();
    });
  },

  _toggleEditForm() {
    hideEditForm = this.hideEditForm;
    this.set( "hideEditForm", !hideEditForm);
  },

  _addNewPost() {
    this._resetPost();
    this._toggleEditForm();
    console.log(hideEditForm);
  },
    
  _callGetUserNewsFeed() {
    let data = {
      apiKey: this.user.apiKey,
      filterBy: this.filterBy,
      // organizationId: this.organization.idOnServer
    }

    this.domHost.toggleModalLoader('Loading news feed...');

    this.callApi('bdemr-get-user-news-feed', data, (err, response) => {
      this.domHost.toggleModalLoader();
      if (response.hasError) {
        console.log(response.error.message);
        this.set('posts', []);
      } 
      else this.set('posts', response.data);
    });
  },

  _callGetOrganizationMemberByRoleApi(organizationId) {
    const data = {
      apiKey: this.user.apiKey,
      organizationId
    };

    this.domHost.toggleModalLoader('Loading members...');
    this.callApi('bdemr-get-organization-member-by-role', data, (err, response) => {
      this.domHost.toggleModalLoader();
      if (response.hasError) {
        this.set('availableMembers', []);
        // this.set('availableSharedList', []); 
        this.set('availableRoles', []); 
        this.domHost.showModalDialog(response.error.message);
      } 
      else {
        members = response.data.members;
        this.set('availableMembers', members) ;
        this._filterMembers(members);
      }
    });
      
  },

  _filterMembers(members) {
    if (members.length == 0) this.set('availableSharedList', []);
    const roleNames = members.map((member) => member.role);
    let uniqRoleNames = ([...new Set(roleNames)]).filter((item) => item != '');
    roles = [];
    uniqRoleNames.forEach((item) => {
      roles.push({
        name: item,
        type: "role"
      });
    });
    let list = roles.concat(members);
    // list = list.sort(( left , right ) => {
    //   const leftCount = left.name;
    //   const rightCount = right.name;
    //   return rightCount - leftCount;
    // });
    
    // this.set("availableSharedList", list);
    this.set("availableRoles", roles);
    
  },

  _getShareWithNames(post) {
    // console.log(post);
    shareWith = post.shareWith;
    if (shareWith.length == 0) return '';
    let str = ''
    shareWith.forEach( item => str += item.name + ', ' );
    return str;
  },

  _onTapSetPost() {
    this._callSetNewsFeedPost( this.post, (newPost)=> {
      this.unshift('posts', newPost);
      this._resetPost();
      this._toggleEditForm();
    });
    
    console.log(this.posts);
  },

  _callSetNewsFeedPost(post, cbfn) {
    post.apiKey = this.user.apiKey;
    post.organizationId = this.organization.idOnServer;

    this.callApi('bdemr-set-news-feed-post', post, (err, response) => {
      if (response.hasError) {
        console.log(response.error.message);
      }
      else {
        newPost = response.data.post
        cbfn(newPost);
      }
    });
      
  },

  _filter(string) {  
    if (!string) return null;
    // string = string.toLowerCase();
    return function(item) {
      let message = item.message;
      let authorName = item.authorName;
      return (message.indexOf(string) != -1 || authorName.indexOf(string) != -1);        
    }
  },

  _getConfirmationCounter(shareWith) {
    totalConfirmed = 0;
    totalCount = shareWith.length
    shareWith.filter((item) => {
      if (item.hasConfirmed) totalConfirmed++
    });

    return totalConfirmed + "/" + totalCount + " Confirmed";

  },

  _checkIfUserExisitForConfirmation(shareWith) {
    const userFound = shareWith.some((item) => item.userId === this.user.idOnServer);
    return userFound;
  },

  _checkIfUserAlreadyConfirmed(shareWith) {
    const userConfirmedAlready = shareWith.some((item) => {
      if (item.userId === this.user.idOnServer) {
        return item.hasConfirmed;
      }
    });
    return userConfirmedAlready;
  },

  _onTapConfirmed (e) {
    post = this.posts[e.model.index];
    members = post.shareWith;
    members.forEach((member, index) => {
      if (member.userId === this.user.idOnServer) {
        post.shareWith[index].hasConfirmed = true;
        this._callSetNewsFeedPost( post, (newPost)=> {
          this._callGetUserNewsFeed();
        });
      }
    });
  },

  onFilterTapped() {
    this._callGetUserNewsFeed();
  },

  _loadChildOrganizationList(organizationIdentifier) {
    this.organizationLoading = true;
    const query = {
      apiKey: this.user.apiKey,
      organizationId: organizationIdentifier
    }
    this.callApi('/bdemr--get-child-organization-list', query, (err, response) => {
      console.log(response);
      this.organizationLoading = false;
      let organizationList = response.data;
      
      if (organizationList.length) {
        organizationList.forEach((item) => {
          this.push("childOrganizationList", { label: item.name, value: item._id });
        })
      }
    })
  },

  organizationSelected(e) {
    if (!e.detail.value) return;
    const organizationId = e.detail.value;
    console.log(e.detail.value);
    this._callGetOrganizationMemberByRoleApi(organizationId);
  },

  navigatedIn() {
    this.push("childOrganizationList", { label: this.organization.name, value: this.organization.idOnServer });
    // this._callGetOrganizationMemberByRoleApi(this.organization.idOnServer);
    // this._callGetUserNewsFeed();
    this._loadChildOrganizationList(this.organization.idOnServer);
  }
});