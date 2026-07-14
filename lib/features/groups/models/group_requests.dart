class CreateGroupRequest {
  const CreateGroupRequest({
    required this.name,
    this.description,
    this.currency,
  });

  final String name;
  final String? description;
  final String? currency;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (currency != null) 'currency': currency,
    };
  }
}

class UpdateGroupRequest {
  const UpdateGroupRequest({
    this.name,
    this.description,
    this.currency,
  });

  final String? name;
  final String? description;
  final String? currency;

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (currency != null) 'currency': currency,
    };
  }
}

class AddGroupMemberRequest {
  const AddGroupMemberRequest({
    required this.email,
  });

  final String email;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class TransferGroupOwnerRequest {
  const TransferGroupOwnerRequest({
    required this.newOwnerUserId,
  });

  final String newOwnerUserId;

  Map<String, dynamic> toJson() {
    return {
      'newOwnerUserId': newOwnerUserId,
    };
  }
}
