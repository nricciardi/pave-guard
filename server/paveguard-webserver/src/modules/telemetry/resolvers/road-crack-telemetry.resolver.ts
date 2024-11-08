import { Resolver, Query, Args, Mutation, Field, ObjectType } from '@nestjs/graphql';
import { TelemetryQuery } from './telemetry.resolver';
import { JwtAuthenticationGuard } from 'src/modules/user/guards/jwt-authentication/jwt-authentication.guard';
import { UseGuards } from '@nestjs/common';
import { AdminGuard } from 'src/modules/user/guards/admin/admin.guard';
import { RoadCrackService } from '../services/road-crack/road-crack.service';
import { CreateRoadCrackTelemetryDto } from '../dto/create-road-crack-telemetry.dto';


@ObjectType()
export class RoadCrackTelemetryQuery extends TelemetryQuery {

  @Field()
  severity: number;
}

@Resolver(() => RoadCrackTelemetryQuery)
export class RoadCrackTelemetryResolver {
  constructor(
    private readonly roadCrackTelemetryService: RoadCrackService
  ) {}

  @Query(() => [RoadCrackTelemetryQuery])
  @UseGuards(AdminGuard)
  async roadCrackTelemetries() {
    return this.roadCrackTelemetryService.findAll();
  }

  @Mutation(() => RoadCrackTelemetryQuery)
  @UseGuards(JwtAuthenticationGuard)
  async createRoadCrackTelemetry(
    @Args() input: CreateRoadCrackTelemetryDto,
  ) {
    return this.roadCrackTelemetryService.create(input);
  }
}

