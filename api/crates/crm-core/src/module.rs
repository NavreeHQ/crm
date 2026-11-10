//! [`CrmCoreModule`]: the CRM tables, their access subjects and the roles
//! seeder.

use navree::api::ModuleBuilderApiExt;
use navree::prelude::*;

use crate::migrations::migrations;
use crate::models::{self, Activity, Company, Contact, Deal, User};
use crate::seed::RolesSeeder;

/// What every CRM feature module builds on: the `crm` migration set (every
/// CRM table), the access subjects `Company`, `Contact`, `Deal`, `Activity`
/// and `User` (so `#[can(.., from = "id")]` routes load their records and
/// `companies.*`, ..., `users.*` permissions map to them) and the
/// `crm-roles` seeder.
///
/// Feature modules import it, so it runs (and seeds) before them:
/// `#[module(imports = [CrmCoreModule], ..)]`.
#[module(
    imports = [
        AccessModule::for_feature::<Company>(),
        AccessModule::for_feature::<Contact>(),
        AccessModule::for_feature::<Deal>(),
        AccessModule::for_feature::<Activity>(),
        AccessModule::for_feature::<User>(),
    ],
    register = Self::wire,
)]
pub struct CrmCoreModule;

impl CrmCoreModule {
    /// Migrations, seeders and the models (no `#[module]` keys for
    /// them). Registered models are what `model:show` describes.
    fn wire(&self, m: &mut ModuleBuilder) {
        // Every client sends a JWT access token (the front ends' backend-for-frontend adds it): the
        // document has no cookie scheme.
        m.api_security(&["bearer"]);
        m.migrations(migrations());
        m.seeder::<RolesSeeder>();
        m.model::<models::Company>()
            .model::<models::Contact>()
            .model::<models::Deal>()
            .model::<models::Activity>()
            .model::<models::User>()
            .model::<models::Role>();
    }
}
