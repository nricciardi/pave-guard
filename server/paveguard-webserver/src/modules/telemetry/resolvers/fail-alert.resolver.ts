import { Resolver, Query, Args, Mutation, Field, ObjectType } from '@nestjs/graphql';
import { TelemetryQuery } from './telemetry.resolver';
import { JwtAuthenticationGuard } from 'src/modules/user/guards/jwt-authentication/jwt-authentication.guard';
import { UseGuards } from '@nestjs/common';
import { AdminGuard } from 'src/modules/user/guards/admin/admin.guard';
import { FailAlertService } from '../services/fail-alert/fail-alert.service';
import { CreateFailTelemetryDto } from '../dto/create-fail-alert.dto';


@ObjectType()
export class FailAlertQuery {

  @Field()
  code: string;

  @Field()
  message: string;
}


@Resolver(() => FailAlertQuery)
export class FailTelemetryResolver {
  constructor(
    private readonly failTelemetryService: FailAlertService,
  ) {}

  @Query(() => [FailAlertQuery])
  @UseGuards(AdminGuard)
  async failAlerts() {
    return this.failTelemetryService.findAll();
  }

  @Mutation(() => FailAlertQuery)
  @UseGuards(JwtAuthenticationGuard)
  async createFailAlert(
    @Args() input: CreateFailTelemetryDto,
  ) {
    return this.failTelemetryService.create(input);
  }
}

